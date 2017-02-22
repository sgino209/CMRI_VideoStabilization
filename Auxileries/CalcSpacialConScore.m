function [score_Con_score, score_weight] = CalcSpacialConScore(mode, I_pre, C1, Sigma, Params, Flow)

persistent score_Con_prev

%% Histogram equalization (preprocess, CLAHE):
I = imadjust(I_pre);

%------------------------------------------------------------------------------------------
%% Mode parsing:
InitHistory   = (mode == 1);
UpdateHistory = (mode == 2);

%------------------------------------------------------------------------------------------
%% Main:
if (InitHistory)
    score_Con_prev = zeros(length(C1),1);
    return

%------------------------------------------------------------------------------------------
%% Contour matching (find best ROI shape):
else 
    C2 = RotateScaleOffsetContour(C1, 0, 0.9, 0, 0);
    C3 = RotateScaleOffsetContour(C1, 0, 1.1, 0, 0);

    C1_smp = SampleImageOnContour(I, C1, Params.WinSize, Sigma, Flow);
    C2_smp = SampleImageOnContour(I, C2, Params.WinSize, Sigma, Flow);
    C3_smp = SampleImageOnContour(I, C3, Params.WinSize, Sigma, Flow);

    score_Con_pre_100 = max(0, sum( 2*C2_smp - C1_smp - C3_smp ));  %% [+,-,-] --> Good

    score_Con_pre_101 = max(0, sum( C2_smp - 2*C1_smp + C3_smp ));  %% [+,-,+] --> Very good

    score_Con_pre_011 = max(0, sum(-2*C2_smp + C1_smp + C3_smp ));  %% [-,+,+] --> Bad (penalty)
    
    score_Con_pre_110 = max(0, sum( C2_smp + C1_smp - 2*C3_smp ));  %% [+,+,-] --> Bad (penalty)
    
    score_Con_pre = NormSoft([1,2,-1,-1]) * [ score_Con_pre_100 ; ...
                                              score_Con_pre_101 ; ...
                                              score_Con_pre_011 ; ...
                                              score_Con_pre_110 ];

    score_Con = smooth(score_Con_pre,3);

    if (UpdateHistory)
        score_Con_prev = score_Con;
    end
    
    gamma = Params.HistoryWeight;
    
    score_Con_final = (1-gamma) * score_Con  +  gamma * score_Con_prev;
    
    score_Con_score = sum( score_Con_final );
                         
    score_weight = NormSoft(NormHard(score_Con_final'));
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Debug: Compare 2 region candidates:
if (Flow.DebugPlotAdvEn)    
    figure('Name','CalcSpacialConScore Debug');
    
    subplot(2,3,1); imshow(I,[]); title('Current Frame (CH1)'); 
    hold on; 
    plot(C1(1,:),C1(2,:),'go-');
    plot(C2(1,:),C2(2,:),'ro--');
    plot(C3(1,:),C3(2,:),'ro--');
    hold off; 
    zoom(1.5);
    
    subplot(2,3,2); bar(score_Con_pre_100,'g'); xlim([0,length(score_Con_pre_100)]); title('Score\_100 [+,-,-]');
    subplot(2,3,3); bar(score_Con_pre_101,'g'); xlim([0,length(score_Con_pre_101)]); title('Score\_101 [+,-,+]');
    subplot(2,3,4); bar(score_Con_pre_011,'r'); xlim([0,length(score_Con_pre_011)]); title('Score\_011 [-,+,+]');
    subplot(2,3,5); bar(score_Con_pre_110,'r'); xlim([0,length(score_Con_pre_110)]); title('Score\_110 [+,+,-]');

    subplot(2,3,6); bar(score_Con,'g'); xlim([0,length(score_Con)]); title('Final score (after LPF, before History)');
end