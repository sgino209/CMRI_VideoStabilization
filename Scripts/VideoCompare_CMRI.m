close all; clear all; clc;

LeftSource  = 'Tracking.avi';
%RightSource = 'C:\Tracking.avi';
TargetFile  = 'Compare.avi';

vidObjRd1 = VideoReader(LeftSource);
%vidObjRd2 = VideoReader(RightSource);

nFrames = vidObjRd1.NumberOfFrames;
%nFrames2 = vidObjRd2.NumberOfFrames;
%nFrames = min([nFrames1,nFrames2]);

vidObjWr = VideoWriter(TargetFile);
    
vidObjWr.FrameRate = vidObjRd1.FrameRate;

open(vidObjWr);

h = figure('Name', 'Stabilization','Units','normalized','Position',[0 0 1 1]);

for k=1:nFrames
    I = read(vidObjRd1, k);
    I1 = imcrop(I,[360.5100  417.0000  171.9800  157.9800]);
    I2 = imcrop(I,[954.5100  417.0000  171.9800  157.9800]);
    %I2 = read(vidObjRd2, k);
    
    subplot(1,2,1);
    imshow(I1);
    title(sprintf('Original (%d/%d)',k,nFrames));
    
    subplot(1,2,2);
    imshow(I2);
    title(sprintf('Stabilized (%d/%d)',k,nFrames));
    
    writeVideo(vidObjWr,getframe(h));
end
close(vidObjWr);