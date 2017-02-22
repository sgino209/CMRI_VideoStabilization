% Simple script for synthesis a tracking target:
%-----------------------------------------------
clear all; close all; clc;
addpath('..\Auxileries');


%--- U S E R   P A R A M E T E R S ----------------------------------------
FrameRows = 256;
FrameCols = 256;
FramesNum = 100;

VideoEn   = 1;
VideoName = 'DemoSoftFilled_withDeforms.avi';

Rotate = -pi/16:pi/32:pi/16;
Scale  = 0.9:0.05:1.1;
Offset = -4:1:4;

NoiseMean = 0.5;
NoiseStd  = 0.1;

ClosedSets   = 'No';   % YES="Hard" , NO="Soft"
Doformations = 'Yes';
RegionFill   = 'Yes';


%--- I N I T I A L I Z A T I O N ------------------------------------------
if (NoiseMean>0 || NoiseStd>0)
    Mue = NoiseMean;
    Sigma = NoiseStd;
    NoiseImage = Mue + Sigma.*randn(FrameRows,FrameCols);
    Background = ones(FrameRows, FrameCols) - NoiseImage;
else
    Background = ones(FrameRows, FrameCols);
end

Initial = [ 92, 112, 155, 175, 175, 155, 112,  92,  92 ;
           120,  96,  96, 120, 143, 158, 158, 146, 120 ];

if strcmp(Doformations,'Yes')
    poly(1,:) = floor( interp1(1:9,Initial(1,:),linspace(1,9,40)) );
    poly(2,:) = floor( interp1(1:9,Initial(2,:),linspace(1,9,40)) );
else
    poly = Initial;
end

h = figure('Name', VideoName);

if (VideoEn)
    vidObj = VideoWriter(fullfile('..\..\InputVideos\',VideoName));
    vidObj.FrameRate = 5;
    open(vidObj);
    set(h, 'Resize', 'off');
end


%--- M A I N   L O O P ----------------------------------------------------
for k=1:FramesNum

    center = floor( mean(poly,2) );

    if strcmp(ClosedSets,'Yes')
        R  = Rotate(randi(length(Rotate),1));
        S  = Scale(randi(length(Scale),1));
        dx = Offset(randi(length(Offset),1));
        dy = Offset(randi(length(Offset),1));
    else
        R  = min(Rotate) + (max(Rotate) - min(Rotate)) .* rand(1,1);
        S  = min(Scale)  + (max(Scale)  - min(Scale))  .* rand(1,1);
        dx = min(Offset) + (max(Offset) - min(Offset)) .* rand(1,1);
        dy = min(Offset) + (max(Offset) - min(Offset)) .* rand(1,1);
    end
    
    poly = RotateScaleOffsetContour(poly, R, S, dx, dy);
    
    
    Background = ones(FrameRows, FrameCols);
        
    if strcmp(RegionFill,'Yes')
        poly_shrink = RotateScaleOffsetContour(poly, 0, 0.75, 0, 0);
        poly_Int = InterpolateContour(poly_shrink, 40*length(poly_shrink));
        BW = im2bw(zeros(FrameRows, FrameCols));
        BW(sub2ind(size(BW),poly_Int(2,:),poly_Int(1,:))) = 1;
        ImMask = imfill(BW,'holes');
        Background = Background - 0.3 * ImMask .* Background;
        
        poly_shrink = RotateScaleOffsetContour(poly, 0, 0.4, 0, 0);
        poly_Int = InterpolateContour(poly_shrink, 40*length(poly_shrink));
        BW = im2bw(zeros(FrameRows, FrameCols));
        BW(sub2ind(size(BW),poly_Int(2,:),poly_Int(1,:))) = 1;
        ImMask = imfill(BW,'holes');
        Background = Background - 0.3 * ImMask .* Background;
    end

    if (NoiseMean>0 || NoiseStd>0)    
        NoiseImage = Mue + Sigma.*randn(FrameRows,FrameCols);
        Background = min(1,Background .* NoiseImage);
    end
        
    imshow(Background);
    hold on;
    plot(poly(1,:), poly(2,:), 'LineWidth', 5);
    xlim([1,FrameCols]);
    ylim([1,FrameRows]);
    title(sprintf('Frame %d --> [R,S,dx,dy]=[%.03f,%.02f,%.02f,%.02f]',k,R,S,dx,-dy));
    drawnow;
    hold off;
    
    if (VideoEn)
        F = getframe(h);
        writeVideo(vidObj,F);
    end

end


%--- D O N E ! ------------------------------------------------------------
if (VideoEn)
    close(vidObj);
end
disp('Completed!');