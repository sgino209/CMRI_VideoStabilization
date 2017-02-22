function [Score_Weights_pts, WinSigma_pts] = UpdateWeights(Channels_curr, ContourAdj, WinSigma_pts, target_samples, ...
                                                           gamma, Score_Weights_pts, flush_history, Params, Flow)

%% Initialize parameters upon flush:
if (flush_history)
    [~, WinSigma_pts, Score_Weights_pts] = InitContourAdj(Channels_curr, ContourAdj, Params, Flow);
else
    %------------------------------------------------------------------------------------------                                                       
    %% Spatial ContourAdj:
    C1 = ContourAdj;
    C2 = RotateScaleOffsetContour(C1, 0, 0.8, 0, 0);
    C3 = RotateScaleOffsetContour(C1, 0, 1.2, 0, 0);

    Sigma = 3*ones(2,50);
    C1_smp = SampleImageOnContour(Channels_curr, C1, Params.WinSize, Sigma, Flow);
    C2_smp = SampleImageOnContour(Channels_curr, C2, Params.WinSize, Sigma, Flow);
    C3_smp = SampleImageOnContour(Channels_curr, C3, Params.WinSize, Sigma, Flow);

    Score_Weights_pts_spatial1 = NormSoft( repmat( abs( sum( C2_smp.ch1 - C1_smp.ch1 ) ), 2, 1) );
    Score_Weights_pts_spatial2 = NormSoft( repmat( abs( sum( C3_smp.ch1 - C1_smp.ch1 ) ), 2, 1) );
    
    Score_Weights_pts_spatial = (Score_Weights_pts_spatial1 + Score_Weights_pts_spatial2) / 2;

    %------------------------------------------------------------------------------------------
    %% Adaptation #1: Update Weights for points - "trusted" points recieve higher weight:
    src_Con_samples = SampleImageOnContour(Channels_curr, ContourAdj, Params.WinSize, WinSigma_pts, Flow);

    min_score_err = [ NormSoft( sum( abs( src_Con_samples.ch1 - target_samples.Con.ch1) ) ) ; ...
                      NormSoft( sum( abs( src_Con_samples.ch2 - target_samples.Con.ch2) ) ) ];

    Score_Weights_pts_err = NormSoft( max(0, Score_Weights_pts_spatial - 0.1*min_score_err ));

    %------------------------------------------------------------------------------------------
    %% Adaptation #2: Update Weights for segments (achieved by smoothing, moving average with span 3):
    Score_Weights_pts_seg(1,:) = NormSoft( smooth(Score_Weights_pts_err(1,:),3)' );
    Score_Weights_pts_seg(2,:) = NormSoft( smooth(Score_Weights_pts_err(2,:),3)' );

    %------------------------------------------------------------------------------------------
    %% Adaptation #3: History weight:
    Score_Weights_pts = NormSoft( (1-gamma) * Score_Weights_pts_seg  +  gamma * Score_Weights_pts );

    %------------------------------------------------------------------------------------------
    %% Adaptation #4: Update window-size (gaussian sigma) for each point - "trusted" points receive a denser window:
    WinSigma_pts = NormHard( ones(2,size(ContourAdj,2)) - Score_Weights_pts ) + 0.1;
end

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn && ~flush_history)
    A = zeros(size(Channels_curr.ch1));
    A(sub2ind(size(A),C1(2,:),C1(1,:))) = Score_Weights_pts_spatial(1,:);
    [~,A] = PreProcess(A);
    
    B = zeros(size(Channels_curr.ch1));
    B(sub2ind(size(B),C1(2,:),C1(1,:))) = Score_Weights_pts_err(1,:);
    [~,B] = PreProcess(B);
    
    C = zeros(size(Channels_curr.ch1));
    C(sub2ind(size(C),C1(2,:),C1(1,:))) = Score_Weights_pts_seg(1,:);
    [~,C] = PreProcess(C);
    
    D = zeros(size(Channels_curr.ch1));
    D(sub2ind(size(D),C1(2,:),C1(1,:))) = Score_Weights_pts(1,:);
    [~,D] = PreProcess(D);

    figure('Name', 'UpdateWeight debug','Units','normalized','Position',[0 0 1 1]);
    subplot(2,3,1);
    subimage(Channels_curr.ch1);
    hold on;
    plot(C1(1,:),C1(2,:),'g');
    plot(C2(1,:),C2(2,:),'r--');
    plot(C3(1,:),C3(2,:),'r--');
    hold off;
    title(sprintf('Frame %d',Flow.FrameIdx));
    zoom(2);

    subplot(2,3,2);
    subimage(filter2(ones(3),im2uint8(A),'same'),jet);
    title('Contour points weights - Spacial only');
    zoom(2); colorbar;
    
    subplot(2,3,3);
    subimage(filter2(ones(3),im2uint8(B),'same'),jet);
    title('Contour points weights - Spacial+Error');
    zoom(2); colorbar;
    
    subplot(2,3,4);
    subimage(filter2(ones(3),im2uint8(C),'same'),jet);
    title('Contour points weights - Spacial+Errors+Seg');
    zoom(2); colorbar;
    
    subplot(2,3,5);
    subimage(filter2(ones(3),im2uint8(D),'same'),jet);
    title('Contour points weights - Spacial+Errors+Seg+History');
    zoom(2); colorbar;
    
    subplot(2,3,6);
    hold on;
    plot(Score_Weights_pts_spatial(1,:),'r');
    plot(Score_Weights_pts_err(1,:),'g');
    plot(Score_Weights_pts_seg(1,:),'b');
    plot(Score_Weights_pts(1,:),'m');
    hold off;
    legend('Spatial Only', '+Errors', '+Segments', '+History', 'Location','Best');
    title('Contour points weighting');
end