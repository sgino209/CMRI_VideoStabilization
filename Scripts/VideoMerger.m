clear all; close all; clc;
tic

%-------------------------------------------------------------------------------------------------------
%% User interface:
[FileName,PathName] = uigetfile('*.avi');
InputVideo1 = fullfile(PathName,FileName);

[FileName,PathName] = uigetfile('*.avi');
InputVideo2 = fullfile(PathName,FileName);

[FileName,PathName] = uigetfile('*.avi');
InputVideo3 = fullfile(PathName,FileName);

[FileName,PathName] = uiputfile('*.avi');
OutputVideo = fullfile(PathName,FileName);

%-------------------------------------------------------------------------------------------------------
%% Merging scheme:
videoFileReader1 = vision.VideoFileReader(InputVideo1);
videoFileReader2 = vision.VideoFileReader(InputVideo2);
videoFileReader3 = vision.VideoFileReader(InputVideo3);
videoFileWriter  = vision.VideoFileWriter(OutputVideo,'FrameRate',videoFileReader1.info.VideoFrameRate);
videoFileWriter.VideoCompressor = 'MJPEG Compressor';

while ~isDone(videoFileReader1)
    J = step(videoFileReader1);
    step(videoFileWriter, J);
end

[M,N,~] = size(J);

while ~isDone(videoFileReader2)
    J = imresize(step(videoFileReader2),[M,N]);
    step(videoFileWriter, J);
end

while ~isDone(videoFileReader3)
    J = imresize(step(videoFileReader3),[M,N]);
    step(videoFileWriter, J);
end

release(videoFileReader1);
release(videoFileReader2);
release(videoFileReader3);
release(videoFileWriter);

fprintf('Completed!\nRuntime = %.02f sec\n', toc);