close all; clear all; clc;

Source = '..\..\InputVideos\Inbar.avi';
Target = '.\InbarDiff.avi';

vidObjRd = VideoReader(Source);

nFrames = vidObjRd.NumberOfFrames;

vidObjWr = VideoWriter(Target);
    
vidObjWr.FrameRate = vidObjRd.FrameRate;

open(vidObjWr);

h = figure('Name', 'DiffCompare','Units','normalized','Position',[0 0 1 1]);

I_prev = read(vidObjRd, 1);
Energy = sum(I_prev(:));
EnergyDiffArr = zeros(1,nFrames);
for k=2:nFrames
    I = read(vidObjRd, k);
    
    I_diff = abs(I - I_prev);    
    
    EnergyDiffRat = sum(I_diff(:)) / Energy;
    EnergyDiffArr(k:end) = repmat(EnergyDiffRat,1,nFrames-k+1);
    
    subplot(2,2,[1,2]);
    plot(EnergyDiffArr,'b');
    hold on;
    plot(repmat(mean(EnergyDiffArr(1:k-1)),1,nFrames),'r');
    hold off;
    title(sprintf('Energy-level (Diffrence Energy / Initial Energy) , Energy=SumOfPixels'));
    
    subplot(2,2,3);
    imshow(I);
    title(sprintf('Original (%d/%d)',k,nFrames));
    
    subplot(2,2,4);
    imshow(I_diff);
    title(sprintf('Difference (%d/%d)',k,nFrames));
    
    I_prev = I;
    
    writeVideo(vidObjWr,getframe(h));
end

close(vidObjWr);