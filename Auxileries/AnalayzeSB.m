function [SB, Winner, Score_Weights_ch] = AnalayzeSB(scoreBoard, Params, Flow)

%------------------------------------------------------------------------------------------
%% Split to channels:
scoreCh1 = scoreBoard(:,:,:,:,1);  % Contour
scoreCh2 = scoreBoard(:,:,:,:,2);  % Region

%------------------------------------------------------------------------------------------
%% Find min/max for each scoreBoard:
MaxScoreCh1 = max(scoreCh1(:));  MinScoreCh1 = min(scoreCh1(:));
MaxScoreCh2 = max(scoreCh2(:));  MinScoreCh2 = min(scoreCh2(:));

%------------------------------------------------------------------------------------------
%% Handle degenerated scerarios (e.g. SB has only 1 candidate):
if (MaxScoreCh1 == MinScoreCh1)
    MinScoreCh1 = 0;  MaxScoreCh1 = 1;
end

if (MaxScoreCh2 == MinScoreCh2)
    MinScoreCh2 = 0;  MaxScoreCh2 = 1;
end

%------------------------------------------------------------------------------------------
%% Normalization (--> [0,1]):
scoreCh1_norm = (scoreCh1 - MinScoreCh1) / (MaxScoreCh1 - MinScoreCh1);
scoreCh2_norm = (scoreCh2 - MinScoreCh2) / (MaxScoreCh2 - MinScoreCh2);

%------------------------------------------------------------------------------------------
%% Adaptive calculation of channels-weights (based on confidence level):
scoreCh1_srt = sort(scoreCh1_norm(:),'descend')';
scoreCh2_srt = sort(scoreCh2_norm(:),'descend')';

scoreCh1_srt_d = abs( diff( scoreCh1_srt ) );
scoreCh2_srt_d = abs( diff( scoreCh2_srt ) );

score_dy1 = NormSoft( Params.ChannelsEn .*  [scoreCh1_srt_d(1), scoreCh2_srt_d(1)] );
score_dy2 = NormSoft( Params.ChannelsEn .*  [scoreCh1_srt_d(2), scoreCh2_srt_d(2)] );
score_dy3 = NormSoft( Params.ChannelsEn .*  [scoreCh1_srt_d(3), scoreCh2_srt_d(3)] );

Score_Weights_ch = NormSoft([4,2,1]) * [ score_dy1 ; score_dy2 ; score_dy3 ];

%------------------------------------------------------------------------------------------
%% Unified weighted scoreBoard:
scoreBoard_norm = scoreCh1_norm * Score_Weights_ch(1) + ...
                  scoreCh2_norm * Score_Weights_ch(2) ;
   
scoreBoardVec = sort(scoreBoard_norm(:),'descend');

%------------------------------------------------------------------------------------------
%% Retrieve winner candidate:
[ind_R, ind_S, ind_dx, ind_dy] = ind2sub(size(scoreBoard_norm), find(scoreBoard_norm==scoreBoardVec(1)));

R  = Params.Rotate(ind_R);
S  = Params.Scale(ind_S);
dx = Params.Offset(ind_dx);
dy = Params.Offset(ind_dy);

Winner.Params = [R,S,dx,dy];

%------------------------------------------------------------------------------------------
%% ScoreBoard characteristics:
if length(scoreBoardVec) > 4
    scoreBoard_max4 = scoreBoardVec(4);
else
    scoreBoard_max4 = scoreBoardVec(1);
end

scoreBoard_mean = mean(scoreBoardVec);

SB.scoreBoard_MaxMean = scoreBoardVec(1) / scoreBoard_mean;
SB.scoreBoard_MaxMax4 = scoreBoardVec(1) / scoreBoard_max4;
SB.scoreBoard         = scoreBoard;


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotEn)
    SB.scoreBoardVec = scoreBoardVec;
end

if (Flow.DebugVerboseEn || Flow.DebugPlotAdvEn)
    [ind_R, ind_S, ind_dx, ind_dy] = ind2sub(size(scoreCh1), find(scoreCh1==max(scoreCh1(:)))); x1=[ind_R,ind_S,ind_dx,ind_dy]';
    [ind_R, ind_S, ind_dx, ind_dy] = ind2sub(size(scoreCh2), find(scoreCh2==max(scoreCh2(:)))); x2=[ind_R,ind_S,ind_dx,ind_dy]';
end

if (Flow.DebugVerboseEn)
    SB.CH1_winner = x1;
    SB.CH2_winner = x2;
end

if (Flow.DebugPlotAdvEn)
    figure('Name', 'SB debug','Units','normalized','Position',[0 0 1 1]);
    
    subplot(2,2,1); bar(scoreCh1_srt); title(sprintf('Contour, var=%.3f, P=[%.2f,%.2f,%.2f,%.2f]',var(scoreCh1_srt),x1)); xlim([0,5]);
    subplot(2,2,2); bar(scoreCh2_srt); title(sprintf('Region,  var=%.3f, P=[%.2f,%.2f,%.2f,%.2f]',var(scoreCh2_srt),x2)); xlim([0,5]);
    
    subplot(2,2,3); bar(Score_Weights_ch,'g'); title('Channels Weights (adaptivly set)');
    
    subplot(2,2,4); 
    plot(scoreCh1_srt,'-or'); 
    hold on;
    plot(scoreCh2_srt,'-og');
    hold off;
    title('SBs after normalization');
    legend('Contour','Region','Location','Best');    
end