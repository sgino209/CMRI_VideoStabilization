close all; clear all; clc;

LeftSource  = '.\InbarOriginal.avi';
RightSource = '.\InbarStabilized.avi';
TargetFile  = '.\InbarCompare.avi';

vidObjRd1 = VideoReader(LeftSource);
vidObjRd2 = VideoReader(RightSource);

nFrames1 = vidObjRd1.NumberOfFrames;
nFrames2 = vidObjRd2.NumberOfFrames;
nFrames = min([nFrames1,nFrames2]);

vidObjWr = VideoWriter(TargetFile);
    
vidObjWr.FrameRate = vidObjRd1.FrameRate;

open(vidObjWr);

h = figure('Name', 'Stabilization','Units','normalized','Position',[0 0 1 1]);

for k=1:nFrames
    I1 = read(vidObjRd1, k);
    I2 = read(vidObjRd2, k);
    
    subplot(1,2,1);
    imshow(I1);
    title(sprintf('Original (%d/%d)',k,nFrames));
    
    subplot(1,2,2);
    imshow(I2);
    title(sprintf('Stabilized (%d/%d)',k,nFrames));
    
    writeVideo(vidObjWr,getframe(h));
end

close(vidObjWr);