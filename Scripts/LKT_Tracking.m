clear all; close all; clc; %#ok<*UNRCH>
tic

ROI_manual_selection = 1;
LastFrameIdx = 120;
DistanceTHR = 10;

%% 1.Create System objects for reading and displaying video and for drawing a bounding box of the object.
[FileName,PathName] = uigetfile('../../InputVideos/Medical/*.*');
InputVideo  = fullfile(PathName,FileName);
OutputVideo = fullfile(PathName,'LKT_result.avi');
videoFileReader = vision.VideoFileReader(InputVideo);
videoFileWriter = vision.VideoFileWriter(OutputVideo,'FrameRate',videoFileReader.info.VideoFrameRate);
videoFileWriter.VideoCompressor = 'MJPEG Compressor';
videoPlayer = vision.VideoPlayer('Position', [100, 100, 680, 520]);
shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 1 0]);

%% 2. Read the first video frame, which contains the object, and then show the object region.
objectFrame = step(videoFileReader);

if (ROI_manual_selection)
    h=figure; imshow(objectFrame); 
    objectRegion=round(getPosition(imrect));
    close(h);
else
    objectRegion = [238, 157, 165, 131];
end

%% 3. Show initial frame with a yellow bounding box.
objectImage = step(shapeInserter, objectFrame, objectRegion);
figure; imshow(objectImage); title('Yellow box shows object region');

%% 4. Detect interest points in the object region
cornerDetector = vision.CornerDetector('Method','Minimum eigenvalue (Shi & Tomasi)');
points = double( step(cornerDetector, rgb2gray(imcrop(objectFrame, objectRegion))) );

%% 5. Translate the coordinates of the detected points so they are relative to the full video frame, not the objectRegion.
points(:, 1) = points(:, 1) + objectRegion(1);
points(:, 2) = points(:, 2) + objectRegion(2);

%% 6. Set up a marker inserter to display points in the video.
markerInserter = vision.MarkerInserter('Shape','Plus','BorderColor','White');

%% 7. Create a tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 1);

%% 8. Initialize the tracker.
initialize(pointTracker, points, objectFrame);

%% 9. Track and display the points in each video frame
idx = 0;
while ~isDone(videoFileReader)
  frame = step(videoFileReader);
  [points, validity, scores] = step(pointTracker, frame);
  if sum(validity) < DistanceTHR
      points = double( step(cornerDetector, rgb2gray(imcrop(objectFrame, objectRegion))) );
      points(:, 1) = points(:, 1) + objectRegion(1);
      points(:, 2) = points(:, 2) + objectRegion(2);
      setPoints(pointTracker, points);
  end
  out1 = step(markerInserter, frame, points(validity, :));
  
  
  %% Stablilize:
  if exist('prevPoints','var')
	pointsDiff =  points.*repmat(validity,1,2) - prevPoints;
	dx = mean( nonzeros( pointsDiff(:,1) ) );
	dy = mean( nonzeros( pointsDiff(:,2) ) ); 
    
    fprintf('Frame=%d: (dx,dy)=(%.2f,%.2f) , norm=%.2f\n',idx,dx,dy,norm(dx,dy));
    
    if (norm(dx,dy)<10)
        
        % Stabilize image:
        xform = [ 1   0   0 ; ...
                  0   1   0 ; ...
                 -dx -dy  1 ]; 
        tform_translate = maketform('affine',xform);
        I_stable = imtransform(frame, tform_translate,...
                               'XData', [1 (size(frame,2)+xform(3,1))],...
                               'YData', [1 (size(frame,1)+xform(3,2))],...
                               'FillValues', .7 );
    else
        I_stable = frame;
    end
    
  else
      
      I_stable = frame;
  end
  
  I_stable_zoom2 = imcrop(imresize_old(I_stable,2),[size(out1,2)/2,size(out1,1)/2,size(out1,2)-1,size(out1,1)-1]);
  
  out2 = [out1 , I_stable_zoom2];
  
  %% Prepare for next frame:
  step(videoPlayer, out2);
  step(videoFileWriter, out2);
  prevPoints = points .* repmat(validity,1,2);  
  idx = idx+1;
  
  if (idx == LastFrameIdx)
      break;
  end
end

%% 10. Release the video reader and player.
release(videoPlayer);
release(videoFileReader);
release(videoFileWriter);

fprintf('Completed!\nRuntime = %.02f sec\n', toc);