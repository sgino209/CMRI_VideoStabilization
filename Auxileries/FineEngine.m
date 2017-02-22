function ContourAdjNL = FineEngine(curr, prev, prev2, flush, Params, Flow)

%% Shrink & Expand (non-linear):
switch Flow.CA_FE_enable

    %------------------------------------------------------------------------------------------------------
    %% Disable:
    case 0
        ContourAdjNL = curr.C;
    
    %------------------------------------------------------------------------------------------------------
    %% Enable:
    case 1
        if (Flow.TempFilt_enable && ~flush.flushCond2)
            I_curr = Calc_I_TF(prev2, prev, curr, Flow);
        else
            I_curr = curr.I;
        end

        ContourAdjNL = NonLinearContourAdjust(curr.C, I_curr, Params, Flow);

    %------------------------------------------------------------------------------------------------------
    %% Enable FE only upon flush
    case 2
        if (isempty(flush.flushCond2) || ~flush.flushCond2)
            ContourAdjNL = curr.C;
        else
            ContourAdjNL = NonLinearContourAdjust(curr.C, curr.I, Params, Flow);
        end
        
    %------------------------------------------------------------------------------------------------------
    otherwise
        warning('MATLAB:paramAmbiguous','Unexpected Flow.CA_FE_enable: %s.',Flow.CA_FE_enable);
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugVerboseEn)   
    center = round( CalcContourCentroid(ContourAdjNL) );
    
    fprintf('#%03d:\t[CA_FE] O=[%d,%d]\n', Flow.FrameIdx, center);
end