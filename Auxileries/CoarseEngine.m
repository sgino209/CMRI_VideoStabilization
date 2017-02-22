function [Winner, SB, Score_Weights_ch] = CoarseEngine(Channels_curr, Contour, target_samples, Params, Flow)

N = length(Contour);

%------------------------------------------------------------------------------------------
%% Coarse-Engine core - exahustive search, finds best linear transformation (CUDA is supported):
if (IsGpuAvailable)
    scoreBoard = CoarseEngineCoreGPU(Channels_curr, Contour, target_samples, Params, Flow);
else
    scoreBoard = CoarseEngineCore(Channels_curr, Contour, target_samples, Params, Flow);
end

%------------------------------------------------------------------------------------------
%% ScoreBoard handling (assign and reconstruct the winner):
[SB, Winner, Score_Weights_ch] = AnalayzeSB(scoreBoard, Params, Flow);

%------------------------------------------------------------------------------------------
%% Winner Mux:
updateCond1 = (SB.scoreBoard_MaxMean > Params.Update_Thr1);
updateCond2 = (SB.scoreBoard_MaxMax4 > Params.Update_Thr2);
updateCond3 = any(Winner.Params ~= [0,1,0,0]);

Winner.updated = updateCond1 && updateCond2 && updateCond3;

if (Winner.updated)   
    % Select "winner" candidate:
    Winner.ContourAdj = RotateScaleOffsetContour(Contour, Winner.Params(1), Winner.Params(2), ... 
                                                          Winner.Params(3), Winner.Params(4));
else
    % Don't do anything if not sure:
    Winner.ContourAdj = Contour;
end

% Update persistent winner for history adaptation:
[~,Winner.PtsWeight] = CalcSpacialConScore(2, Channels_curr.ch1, Winner.ContourAdj, 3*ones(1,N), Params, Flow);


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugVerboseEn)   
    center = round( CalcContourCentroid(Winner.ContourAdj) );

    isPrior = '';
    if ( Flow.CE_usePriors && (Winner.Params(1) == Params.RotPri) )
        isPrior = '(P)';
    end
        
    fprintf('#%03d:\t[CA_CE] MAX/MEAN=%.02f, MAX/MAX4=%.02f, WHTs=[Con,Reg]=[%.02f,%.02f]\n',...
            Flow.FrameIdx, SB.scoreBoard_MaxMean, SB.scoreBoard_MaxMax4, Score_Weights_ch);
    fprintf('#%03d:\t[CA_CE] Contour Winner=[%d,%d,%d,%d]\n', Flow.FrameIdx, SB.CH1_winner);
    fprintf('#%03d:\t[CA_CE] Region  Winner=[%d,%d,%d,%d]\n', Flow.FrameIdx, SB.CH2_winner); 
    Winner_Params = [find(Winner.Params(1)==Params.Rotate),...
                     find(Winner.Params(2)==Params.Scale),...
                     find(Winner.Params(3)==Params.Offset),...
                     find(Winner.Params(4)==Params.Offset)];
    fprintf('#%03d:\t[CA_CE] O=[%d,%d], [R,S,dx,dy]=[%d,%d,%d,%d]=[%.03f%s,%.02f,%d,%d], ChDist=%.02f\n',...
            Flow.FrameIdx, center, Winner_Params(1), Winner_Params(2), Winner_Params(3), Winner_Params(4),...
			Winner.Params(1), isPrior, Winner.Params(2), Winner.Params(3), Winner.Params(4), ...
            norm([SB.CH1_winner , SB.CH2_winner]' - repmat(Winner_Params,2,1)));
end

%--------------------------------------------------------------------------------------
%% Debug #1: Compare 2 candidates (Contour vs. Region winners):
if (Flow.DebugPlotAdvEn)
    
    RSXY1 = SB.CH1_winner;
    RSXY2 = SB.CH2_winner;
    
    R1=Params.Rotate(RSXY1(1)); S1=Params.Scale(RSXY1(2)); dx1=Params.Offset(RSXY1(3)); dy1=Params.Offset(RSXY1(4));
    R2=Params.Rotate(RSXY2(1)); S2=Params.Scale(RSXY2(2)); dx2=Params.Offset(RSXY2(3)); dy2=Params.Offset(RSXY2(4));
    
    C1 = RotateScaleOffsetContour(Contour, R1, S1, dx1, dy1);
    C2 = RotateScaleOffsetContour(Contour, R2, S2, dx2, dy2);
    
    SR1_pre1 = SampleImageInsideContour(Channels_curr, C1, Flow);
    SR2_pre1 = SampleImageInsideContour(Channels_curr, C2, Flow);
    
    ME1.dX=dx1; ME1.dY=dy1; ME1.Rotation=R1; ME1.Scale=S1; ME1.ScaleEn=1; ME1.ScaleRef=size(target_samples.ch1);
    SR1_pre2.ch1=MotionCompansation(SR1_pre1.ch1, C1, ME1, Flow);
    
    ME2.dX=dx2; ME2.dY=dy2; ME2.Rotation=R2; ME2.Scale=S2; ME2.ScaleEn=1; ME2.ScaleRef=size(target_samples.ch1);
    SR2_pre2.ch1=MotionCompansation(SR2_pre1.ch1, C2, ME2, Flow);

    [~,SR1.ch1] = PreProcess(SR1_pre2.ch1);
    [~,SR2.ch1] = PreProcess(SR2_pre2.ch1);
    [~,TF]      = PreProcess(target_samples.ch1);
    
    CC1 = RotateScaleOffsetContour(C1, -R1, 1/S1, -dx1, -dy1);
    CC2 = RotateScaleOffsetContour(C2, -R2, 1/S2, -dx2, -dy2);
    
    ImMask1 = roipoly(TF, CC1(1,:), CC1(2,:));
    ImMask2 = roipoly(TF, CC2(1,:), CC2(2,:));

    %----------------------------------------------------------------------------------
   
    figure('Name','CE Debug (Region)','Units','normalized','Position',[0 0 1 1]);

    h1=subplot(3,3,1); imshow(imfuse(SR1.ch1,TF)); title(sprintf('Con. (%.2f) [R,S,dx,dy] = [%d,%d,%d,%d]',Score_Weights_ch(1),RSXY1)); zoom(1.5);
    h2=subplot(3,3,2); imshow(imfuse(SR2.ch1,TF)); title(sprintf('Reg. (%.2f) [R,S,dx,dy] = [%d,%d,%d,%d]',Score_Weights_ch(2),RSXY2)); zoom(1.5);
    h3=subplot(3,3,3); imshow(target_samples.ch1); title('TGT'); zoom(1.5);
    h4=subplot(3,3,4); imshow(SR1_pre1.ch1); title('SRC (pre)'); zoom(1.5);
    h5=subplot(3,3,5); imshow(SR2_pre1.ch1); title('SRC (pre)'); zoom(1.5);
    h6=subplot(3,3,6); imshow(Channels_curr.ch2); title('Texture'); zoom(1.5);
    h7=subplot(3,3,7); imshow(ImMask1 .* abs(TF-SR1.ch1)); title('DIFF'); zoom(1.5);
    h8=subplot(3,3,8); imshow(ImMask2 .* abs(TF-SR2.ch1)); title('DIFF'); zoom(1.5);
    linkaxes([h1 h2 h3 h4 h5 h6 h7 h8]);
    subplot(3,3,9);
    imshow(Channels_curr.ch1);
    hold on;
    plot(C1(1,:),C1(2,:),'r');
    plot(C2(1,:),C2(2,:),'g');
    plot(Contour(1,:),Contour(2,:),'b');
    hold off;
    legend(sprintf('[R,S,dx,dy] = [%d,%d,%d,%d]',RSXY1),...
           sprintf('[R,S,dx,dy] = [%d,%d,%d,%d]',RSXY2),'Orig','Location','Best');
    zoom(1.5);
end

%--------------------------------------------------------------------------------------
%% Debug #2: Compare 2 candidates (Contour vs. Region winners):
if (Flow.DebugPlotAdvEn)

    RSXY1 = SB.CH1_winner;
    RSXY2 = SB.CH2_winner;
    
    R1=Params.Rotate(RSXY1(1)); S1=Params.Scale(RSXY1(2)); dx1=Params.Offset(RSXY1(3)); dy1=Params.Offset(RSXY1(4));
    R2=Params.Rotate(RSXY2(1)); S2=Params.Scale(RSXY2(2)); dx2=Params.Offset(RSXY2(3)); dy2=Params.Offset(RSXY2(4));
    
    C1 = RotateScaleOffsetContour(Contour, R1, S1, dx1, dy1);
    C2 = RotateScaleOffsetContour(Contour, R2, S2, dx2, dy2);
    
    [~,ContPointsWeight] = CalcSpacialConScore(0, Channels_curr.ch1, C1, 3*ones(1,N), Params, Flow);
   
    A = zeros(size(Channels_curr.ch1));
    A(sub2ind(size(A),C1(2,:),C1(1,:))) = ContPointsWeight;
    [~,A] = PreProcess(A);
    
    B = zeros(size(Channels_curr.ch1));
    B(sub2ind(size(B),Winner.ContourAdj(2,:),Winner.ContourAdj(1,:))) = Winner.PtsWeight;
    [~,B] = PreProcess(B);
    
    %----------------------------------------------------------------------------------    
        
    figure('Name','CE Debug (Contour)','Units','normalized','Position',[0 0 1 1]);
    
    subplot(2,2,[1 3]);
    imshow(Channels_curr.ch1); 
    hold on; 
    plot(C1(1,:),C1(2,:),'r'); 
    plot(C2(1,:),C2(2,:),'g'); 
    plot(Winner.ContourAdj(1,:),Winner.ContourAdj(2,:),'b--');
    hold off;
    legend(sprintf('Contour - [R,S,dx,dy] = [%d,%d,%d,%d]',RSXY1),...
           sprintf('Region  - [R,S,dx,dy] = [%d,%d,%d,%d]',RSXY2),...
           sprintf('Winner  - [R,S,dx,dy] = [%d,%d,%d,%d]',Winner_Params),...
           'Location','Best');
    zoom(1.5);
        
    subplot(2,2,2);
    subimage(filter2(ones(3),im2uint8(A),'same'),jet); title('Contour Winner - points weights'); zoom(1.5);

    subplot(2,2,4);
    subimage(filter2(ones(3),im2uint8(B),'same'),jet); title('Total (Con/Reg) Winner - points weights'); zoom(1.5);
end