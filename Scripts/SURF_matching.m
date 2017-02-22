clear all; close all; clc;
addpath('..\Auxileries');

%% User parameters:
MODE = 'Brightness';  % 'Brightness' / 'SORF' / 'LF'

%% Load two frames:
videoFReader = vision.VideoFileReader('..\..\InputVideos\Medical\CMRI_TC_ShortAxis.wmv');

hh=msgbox('Please select ROI to be cropped', 'ROI Selection');
uiwait(hh);

switch MODE
    case 'Brightness'     
        [original, rect]  = imcrop( rgb2gray( step(videoFReader) )); close;
        distorted = imcrop( rgb2gray( step(videoFReader) ), rect);    
    
    case 'SORF'
        [original, rect]  = imcrop( CalculateSORF( rgb2gray( step(videoFReader) ) )); close;
        distorted = imcrop( CalculateSORF( rgb2gray( step(videoFReader) ) ), rect);    
    
    case 'LF'
        [original, rect]  = imcrop( CalculateLF( rgb2gray( step(videoFReader) ) )); close;
        distorted = imcrop( CalculateLF( rgb2gray( step(videoFReader) ) ), rect);    
    
    otherwise
        warning('MATLAB:paramAmbiguous','Illegal MODE: %s.',MODE);
end

release(videoFReader);

%% Detect features in both images.
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);

%% Extract feature descriptors.
[featuresIn,   validPtsIn] = extractFeatures(original,  ptsOriginal);
[featuresOut, validPtsOut] = extractFeatures(distorted, ptsDistorted);

%% Match features by using their descriptors.
index_pairs = matchFeatures(featuresIn, featuresOut);

if size(index_pairs,1) < 2
    hh=msgbox('Couldnt find any matching SURF points for these images...', 'Error');
    uiwait(hh);
    return
end

%% Retrieve locations of corresponding points for each image.
matchedOriginal  = validPtsIn(index_pairs(:,1));
matchedDistorted = validPtsOut(index_pairs(:,2));

%% Show point matches. Notice the presence of outliers.
figure('Name','SURF matching','Units','normalized','Position',[0 0 1 1]);
subplot(2,2,1);
showMatchedFeatures(original,distorted,matchedOriginal,matchedDistorted);
title('Putatively matched points (including outliers)');

%% Estimate Transformation.
geoTransformEst = vision.GeometricTransformEstimator; % defaults to RANSAC

% Configure the System object.
geoTransformEst.Transform = 'Nonreflective similarity';
geoTransformEst.NumRandomSamplingsMethod = 'Desired confidence';
geoTransformEst.MaximumRandomSamples = 1000;
geoTransformEst.DesiredConfidence = 99.8;

% Invoke the step() method on the geoTransformEst object to compute the
% transformation from the distorted to the original image.
% You may see varying results of the transformation matrix computation because
% of the random sampling employed by the RANSAC algorithm.
[tform_matrix, inlierIdx] = step(geoTransformEst, matchedDistorted.Location, matchedOriginal.Location);

%% Display matching point pairs used in the computation of the transformation matrix.
subplot(2,2,2);
showMatchedFeatures(original,distorted,matchedOriginal(inlierIdx), matchedDistorted(inlierIdx));
title('Matching points (inliers only)');
legend('ptsOriginal','ptsDistorted');

%% Solve for Scale and Angle
tform_matrix = cat(2,tform_matrix,[0 0 1]'); % pad the matrix
Tinv  = inv(tform_matrix);

ss = Tinv(2,1);
sc = Tinv(1,1);
scale_recovered = sqrt(ss*ss + sc*sc);
theta_recovered = atan2(ss,sc)*180/pi;

%% Recover the Original Image
t = maketform('affine', double(tform_matrix));
D = size(original);
recovered = imtransform(distorted,t,'XData',[1 D(2)],'YData',[1 D(1)]);
subplot(2,2,[3 4]); imshowpair(original,recovered,'montage')
title(sprintf('Estimated scaling = %.3f, Estimated rotation = %.3f', scale_recovered, theta_recovered));