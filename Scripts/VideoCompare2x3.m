clear all; close all; clc;
tic

%-------------------------------------------------------------------------------------------------------
%% User interface:
PathName = uigetdir('../../Results/Medical/comparison');

%% FileNames:
FileName1 = 'Input.avi';
FileName2 = 'LKT.avi';
FileName3 = 'TemplateMatching.avi';
FileName4 = 'Youtube.mp4';
FileName5 = 'Ours_MSE.avi';
FileName6 = 'Ours_SSIM.avi';

InputVideo1 = fullfile(PathName,FileName1);
InputVideo2 = fullfile(PathName,FileName2);
InputVideo3 = fullfile(PathName,FileName3);
InputVideo4 = fullfile(PathName,FileName4);
InputVideo5 = fullfile(PathName,FileName5);
InputVideo6 = fullfile(PathName,FileName6);

%-------------------------------------------------------------------------------------------------------
%% System Objects init.:
videoFileReader1 = vision.VideoFileReader(InputVideo1);
videoFileReader2 = vision.VideoFileReader(InputVideo2);
videoFileReader3 = vision.VideoFileReader(InputVideo3);
videoFileReader4 = vision.VideoFileReader(InputVideo4);
videoFileReader5 = vision.VideoFileReader(InputVideo5);
videoFileReader6 = vision.VideoFileReader(InputVideo6);

videoFileWriter  = vision.VideoFileWriter('Compare2x3.avi','FrameRate',videoFileReader1.info.VideoFrameRate);
videoFileWriter.VideoCompressor = 'MJPEG Compressor';

while ( ~isDone(videoFileReader1) && ~isDone(videoFileReader2) && ~isDone(videoFileReader3) && ...
        ~isDone(videoFileReader4) && ~isDone(videoFileReader5) && ~isDone(videoFileReader6) )
    J1 = step(videoFileReader1);
    J2 = step(videoFileReader2);
    J3 = step(videoFileReader3);
    J4 = step(videoFileReader4);
    J5 = step(videoFileReader5);
    J6 = step(videoFileReader6);
    
    I1_pre = J1;
    I2_pre = J2(:,round(size(J2,2)/2):end,:);
    I3_pre = J3(:,round(size(J3,2)/2):end,:);
    I4_pre = J4;
    I5_pre = J5(:,round(size(J5,2)/2):end,:);
    I6_pre = J6(:,round(size(J6,2)/2):end,:);
    
    I1 = imresize(I1_pre, [300,400]);
    I2 = imresize(I2_pre, [300,400]);
    I3 = imresize(I3_pre, [300,400]);
    I4 = imresize(I4_pre, [300,400]);
    I5 = imresize(I5_pre, [300,400]);
    I6 = imresize(I6_pre, [300,400]);    
    
    out = [ I1 , I2 , I3 ; I4 , I5 , I6 ];
    
    step(videoFileWriter, out);
end

release(videoFileReader1);
release(videoFileReader2);
release(videoFileReader3);
release(videoFileReader4);
release(videoFileReader5);
release(videoFileReader6);
release(videoFileWriter);

fprintf('Completed!\nRuntime = %.02f sec\n', toc);