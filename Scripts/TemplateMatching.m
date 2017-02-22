clear all; close all; clc; %#ok<*UNRCH>
tic

%--------------------------------------------------------------------------------------------------------
%% User parameters:
k = 1;
FrameStart  = 40*(k-1)+1;
FrameStop   = 40*k;
DistanceTHR = 10;
PlayerEn    = 0;
sizeBoostFact = 0.5;

[FileName,PathName] = uigetfile('../../InputVideos/Medical/*.*');
InputVideo  = fullfile(PathName,FileName);
OutputVideo = sprintf('TemplateMatching_%d_%d.avi',FrameStart,FrameStop);

%--------------------------------------------------------------------------------------------------------
%% 1.Create System objects for reading and displaying video and for drawing a bounding box of the object.
videoFileReader = vision.VideoFileReader(InputVideo);
videoFileWriter = vision.VideoFileWriter(OutputVideo,'FrameRate',videoFileReader.info.VideoFrameRate);
shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 1 0]);
htm=vision.TemplateMatcher; 
hmi = vision.MarkerInserter('Size', 10, 'Fill', true, 'FillColor', 'White', 'Opacity', 0.75);
if (PlayerEn)
    videoPlayer = vision.VideoPlayer('Position', [100, 100, 680, 520]);
end

%--------------------------------------------------------------------------------------------------------
%% 2. Read the first video frame, which contains the object, and then show the object region.
FrameIdx = 0;
for k=1:FrameStart
    I = step(videoFileReader);
    FrameIdx = FrameIdx + 1;
end

%% Select ROI:
h=figure; imshow(I); 
objectRegion=round(getPosition(imrect));
close(h);

%--------------------------------------------------------------------------------------------------------
%% 3. Track and display the target template in each video frame.
prevLoc = [(2*objectRegion(1)+objectRegion(3))/2 , (2*objectRegion(2)+objectRegion(4))/2];
while ~isDone(videoFileReader) && (FrameIdx < FrameStop)
 
    % increment videoReader:
    I = step(videoFileReader);

    if exist('T','var')
        
        % Find the [x y] coordinates of the template's center:
        I1 = imresize_old( rgb2gray(I),sizeBoostFact );
        I2 = imresize_old( rgb2gray(T),sizeBoostFact );
        Loc = step(htm,I1,I2) / sizeBoostFact;

        dx = double( Loc(1)-prevLoc(1) );
        dy = double( Loc(2)-prevLoc(2) );
        
        fprintf('Frame %d: (dx,dy)=(%d,%d), norm=%.2f\n',FrameIdx, dx, dy, norm([dx dy]));
        
        if (norm([dx dy]) < DistanceTHR)        
            objectRegion(1) = objectRegion(1) + dx;
            objectRegion(2) = objectRegion(2) + dy;

            % Stabilize image:
            xform = [ 1   0   0 ; ...
                      0   1   0 ; ...
                     -dx -dy  1 ]; 
            tform_translate = maketform('affine',xform);
            I_stable = imtransform(I, tform_translate,...
                      'XData', [1 (size(I,2)+xform(3,1))],...
                      'YData', [1 (size(I,1)+xform(3,2))],...
                      'FillValues', .7 );
            prevLoc = Loc;
            
        else
            Loc = prevLoc;
            I_stable = I;
        end
        
    else
        Loc = prevLoc;
        I_stable = I;
    end

    % Mark the location on the image using white disc:
    objectImage = step(shapeInserter, I, objectRegion);
    release(hmi);
    J = step(hmi, objectImage, Loc);
    
    % Increment videoPlayer:
    if (PlayerEn)
        step(videoPlayer, J);
    end
    
    % increment VideoWriter:
    I_stable_zoom2 = imcrop(imresize_old(I_stable,2),2*objectRegion+[-50 -50 100 100]);
    s1 = size(J);
    s2 = size(I_stable_zoom2);
    CropRect = [ round((s1(2)-s2(2))/2), round((s1(1)-s2(1))/2), s2(2)-1, s2(1)-1 ];
    J = imcrop(J,CropRect);
    
	step(videoFileWriter, [J I_stable_zoom2]);
    
    % Extract target template (for next frame):
    T = imcrop(I, objectRegion);
    
    FrameIdx = FrameIdx + 1;
end

%--------------------------------------------------------------------------------------------------------
%% 4. Release the video system-objects.
release(videoFileReader);
release(videoFileWriter);
release(shapeInserter);
if (PlayerEn)
    release(videoPlayer);
end

fprintf('Completed!\nRuntime = %.02f sec\n', toc);