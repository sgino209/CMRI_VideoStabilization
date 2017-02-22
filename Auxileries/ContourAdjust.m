% Target:  Adjust previous frame Contour_pre to fit current frame

function CA = ContourAdjust(I_curr, Contour_pre, Params, Flow)

persistent I_prev
persistent I_prev2
persistent Contour_prev2
persistent ContourRef

%------------------------------------------------------------------------------------------
%% Manual selection of the Contour_pre (for semi-automatic usage):
ManualCA = ~mod(Flow.FrameIdx,Flow.Manual_CA);
if (ManualCA)
    htmp=figure;
    imshow(I_curr,'InitialMagnification',250);
    hh=msgbox('Please select ROI (contour)', 'ROI Selection');
    uiwait(hh);
    hh = impoly;
    tt = wait(hh);
    tt = [tt; tt(1,:)]';
    close(htmp);
    
    Contour_pre = InterpolateContour(tt, Params.ContourPts);
end

%------------------------------------------------------------------------------------------
%% Bypass options (either first or manual frame):
if (Flow.FrameIdx == Flow.StartAtFrm) || ManualCA
    ContourRef    = Contour_pre;
    Contour_prev2 = ContourRef;
    I_prev        = I_curr;
    I_prev2       = I_prev;
    
    CA.Contour    = ContourRef;    
    CA.ContourRef = ContourRef;
    CA.LinParams  = [0,1,0,0];
    CA.BypassFE   = 1;
    CA.Flush      = 0;

    CalcSpacialConScore(1, I_curr, Contour_pre, 3*ones(1,50), Params, Flow);
    
    return
end

%------------------------------------------------------------------------------------------
%% Channels generation:
[Channels_prev, Channels_curr] = GenerateChannels(I_prev, I_curr);

%------------------------------------------------------------------------------------------
%% Generate Target (persistents, history samples):
target_samples = GenerateTargets(Channels_prev, Contour_pre, Flow);

%------------------------------------------------------------------------------------------
%% Use medical priors if exists for better accuracy (Cardiac lower boundary line in CMRI):
if (Flow.CE_usePriors)
    [R_prev, ~] = UsePriorsCMRI(Contour_pre, I_prev, Flow);
    [R_curr, ~] = UsePriorsCMRI(Contour_pre, I_curr, Flow);

    Params.RotPri = R_curr(1)-R_prev(1);
    if ( Params.RotPri > 1.1*min(Params.Rotate) && ...
         Params.RotPri < 1.1*max(Params.Rotate) )
        Params.Rotate = unique([Params.Rotate, Params.RotPri]);
    end
end

%------------------------------------------------------------------------------------------
%% Coarse Engine (CE) - SSD best-match:
[Winner, SB, Score_Weights_ch] = CoarseEngine(Channels_curr, Contour_pre, target_samples, Params, Flow);

%------------------------------------------------------------------------------------------
%% Flush history decision (low confidence level), CE based:
EdgesDiffRatio = mean2(Channels_curr.ch2) / mean2(Channels_prev.ch2);

flush.flushCond1 = (SB.scoreBoard_MaxMean < Params.Flush_Thr1);  % --> SB uncertainty
flush.flushCond2 = (abs(1-EdgesDiffRatio) > Params.Flush_Thr2);  % --> Temporal edge

flush.flush_history = flush.flushCond1 || flush.flushCond2;

if (flush.flush_history)
	CalcSpacialConScore(1, I_curr, Contour_pre, 3*ones(1,50), Params, Flow);
end

%------------------------------------------------------------------------------------------
%% Fine Engine (FE) - "Shrink & Expand":
curr.I  = I_curr;   curr.C  = Winner.ContourAdj;
prev.I  = I_prev;   prev.C  = Contour_pre;
prev2.I = I_prev2;  prev2.C = Contour_prev2;

Winner.ContourAdjNL = FineEngine(curr, prev, prev2, flush, Params, Flow);

%------------------------------------------------------------------------------------------
%% Pack results for ME stage:
CA.Contour    = Winner.ContourAdjNL;
CA.ContourRef = ContourRef;
CA.LinParams  = Winner.Params;
CA.BypassCE   = ~Winner.updated;
CA.BypassFE   = (Flow.CA_FE_enable == 0) || ...
                (Flow.CA_FE_enable == 2) && ~flush.flushCond2;

%------------------------------------------------------------------------------------------
%% Update I_PREV for next call:
Contour_prev2 = Contour_pre;
I_prev2 = I_prev;
I_prev = I_curr;


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DebugContourAdjust(Channels_curr, Winner, SB, flush, Score_Weights_ch, EdgesDiffRatio, CA, Flow, Params);