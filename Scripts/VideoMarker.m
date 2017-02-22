clear all; close all; clc;
tic

%-------------------------------------------------------------------------------------------------------
%% User interface:
[FileName,PathName] = uigetfile('*.*');
InputVideo  = fullfile(PathName,FileName);

dot = strfind(FileName,'.');
OutputVideo = fullfile(PathName,[FileName(1:dot-1),'_marked',FileName(dot:end)]);

%-------------------------------------------------------------------------------------------------------
%% Marking scheme:
videoFileReader = vision.VideoFileReader(InputVideo);
videoFileWriter = vision.VideoFileWriter(OutputVideo,'FrameRate',videoFileReader.info.VideoFrameRate);
videoFileWriter.VideoCompressor = 'MJPEG Compressor';

while ~isDone(videoFileReader)
    I_ = rgb2gray( step(videoFileReader) );
    
    I(:,:,1) = imadjust(I_);
    I(:,:,2) = imadjust(I_);
    I(:,:,3) = imadjust(I_);
    
    J = zeros(size(I));
    J(size(J,1)/2-1:size(J,1)/2+1,:,1) = 1;
    
    step(videoFileWriter, imfuse(I,J,'blend'));
end

release(videoFileReader);
release(videoFileWriter);

fprintf('Completed!\nRuntime = %.02f sec\n', toc);