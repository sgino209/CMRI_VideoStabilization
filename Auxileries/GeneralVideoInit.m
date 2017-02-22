function [xyloObj, nFrames] = GeneralVideoInit(pathname, filename)

% Load video:
xyloObj = VideoReader(fullfile(pathname, filename));

% Number of frames:
nFrames = xyloObj.NumberOfFrames;