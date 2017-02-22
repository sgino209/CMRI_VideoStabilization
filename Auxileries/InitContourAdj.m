function [gamma, WinSigma_pts, Score_Weights_pts] = InitContourAdj(Channels, Contour, Params, Flow)

N = size(Contour,2);

%------------------------------------------------------------------------------------------
%% Initialize Gamma parameter:
gamma = 0;

%------------------------------------------------------------------------------------------
%% Initialize scoring weights (pts, sigma):
Initial_WinSigma = Params.ContourSigma * ones(2,N);
WinSigma_pts = Initial_WinSigma;

%------------------------------------------------------------------------------------------
%% Spatial importance:
C1 = Contour;
C2 = RotateScaleOffsetContour(C1, 0, 0.8, 0, 0);
C3 = RotateScaleOffsetContour(C1, 0, 1.2, 0, 0);

Sigma = 3*ones(2,50);
C1_smp = SampleImageOnContour(Channels, C1, Params.WinSize, Sigma, Flow);
C2_smp = SampleImageOnContour(Channels, C2, Params.WinSize, Sigma, Flow);
C3_smp = SampleImageOnContour(Channels, C3, Params.WinSize, Sigma, Flow);

Score_Weights_pts_pre1 = NormSoft( repmat( abs( sum( C2_smp.ch1 - C1_smp.ch1 ) ), 2, 1) );
Score_Weights_pts_pre2 = NormSoft( repmat( abs( sum( C3_smp.ch1 - C1_smp.ch1 ) ), 2, 1) );

Score_Weights_pts_pre = (Score_Weights_pts_pre1 + Score_Weights_pts_pre2) / 2;

%% Update Weights for segments (achieved by smoothing, moving average with span 3):
Score_Weights_pts(1,:) = NormSoft( smooth(Score_Weights_pts_pre(1,:),3)' );
Score_Weights_pts(2,:) = NormSoft( smooth(Score_Weights_pts_pre(2,:),3)' );
    
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Debug: Compare 2 region candidates:
if (Flow.DebugPlotAdvEn)

    figure('Name','InitContourAdj debug');
    
    subplot(2,3,1);
    imshow(Channels.ch1,[]);
    hold on;
    plot(C1(1,:),C1(2,:),'g');
    plot(C2(1,:),C2(2,:),'r');
    plot(C3(1,:),C3(2,:),'r');
    hold off;
    title('Input image');
    zoom(2);
    
    subplot(2,3,2);
    surface(fspecial('gaussian', Params.WinSize, mean(Sigma(1,:)))); view(80,50);
    title('Sampling kernel');
    
    A = zeros(size(Channels.ch1));
    A(sub2ind(size(A),Contour(2,:),Contour(1,:))) = Score_Weights_pts(1,:);
    [~,A] = PreProcess(A);

    B = zeros(size(Channels.ch1));
    B(sub2ind(size(B),Contour(2,:),Contour(1,:))) = sum( C1_smp.ch1 );
    [~,B] = PreProcess(B);
    
    C = zeros(size(Channels.ch1));
    C(sub2ind(size(C),Contour(2,:),Contour(1,:))) = sum( C2_smp.ch1 );
    [~,C] = PreProcess(C);

    D = zeros(size(Channels.ch1));
    D(sub2ind(size(D),Contour(2,:),Contour(1,:))) = sum( C3_smp.ch1 );
    [~,D] = PreProcess(D);

    subplot(2,3,3);
    subimage(filter2(ones(3),im2uint8(A),'same'),jet); title('Contour points weights'); zoom(2);
    
    subplot(2,3,4);
    subimage(filter2(ones(3),im2uint8(B),'same'),jet); title('Contour points weights (Middle)'); zoom(2);

    subplot(2,3,5);
    subimage(filter2(ones(3),im2uint8(C),'same'),jet); title('Contour points weights (Shrinked)'); zoom(2);

    subplot(2,3,6);
    subimage(filter2(ones(3),im2uint8(D),'same'),jet); title('Contour points weights (Expanded)'); zoom(2);    

end