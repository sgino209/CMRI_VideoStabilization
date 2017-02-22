function Out = SampleImageInsideContour(Channels, Contour, Flow)

%% Crop the Region-Of-Interest (ROI):
ImMask = roipoly(Channels.ch1, Contour(1,:), Contour(2,:));

Out.Area = sum(ImMask(:));

I1_ROI = ImMask .* Channels.ch1;
I2_ROI = ImMask .* Channels.ch2;

%% Generate output:
Out.ch1  = I1_ROI;
Out.ch2  = I2_ROI;


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    figure('Name','Region Sampling Debug');
    
    h1=subplot(1,2,1); imshow(I1_ROI,[]); title('CH1: Brighness');
    h2=subplot(1,2,2); imshow(I2_ROI,[]); title('CH2: SORF');
    
    linkaxes([h1 h2]);
end