function ME = MotionEstimation(ContourRef, CA, Flow)

persistent prevParams

SCR = zeros(360,1);

if ((Flow.FrameIdx == Flow.StartAtFrm) || ~mod(Flow.FrameIdx,Flow.Manual_CA)) %|| (CA.BypassCE && CA.BypassFE))
    ME.Rotation  = 0;
    ME.Scale     = 1;
    ME.dX        = 0;
    ME.dY        = 0;
    

elseif (CA.BypassFE)
    ME.Rotation  = CA.LinParams(1) + prevParams.Rot;
    ME.Scale     = CA.LinParams(2) * prevParams.Scl;
    ME.dX        = CA.LinParams(3) + prevParams.dX;
    ME.dY        = CA.LinParams(4) + prevParams.dY;

else

    %% Calculate Centroids (for Offset & Scale estimation):
    center_curr = CalcContourCentroid(CA.Contour);
    center_ref  = CalcContourCentroid(ContourRef);

    %% Estimate Offset:
    dx = center_curr(1) - center_ref(1);
    dy = center_curr(2) - center_ref(2);

    %% Estimate Scale (Distance from center ratio):
    Scale = norm(CA.Contour - repmat(center_curr', 1, length(CA.Contour))) / ...
            norm(ContourRef - repmat(center_ref' , 1, length(ContourRef)));

    %% Estimate Rotation (Area-Similarity-Metric):
    if (Flow.usePCA_forME)
        COEFF1 = princomp(ContourRef');
        COEFF2 = princomp(CA.Contour');
              
        Rotation = asin(COEFF2(2)) - asin(COEFF1(2));
        
    else
        IND = 1;
        if Flow.ParentFE
            ROT = linspace(-pi/4,pi/4,90);
        else
            ROT = linspace(-pi/8,pi/8,90) + prevParams.Rot;
        end
        Rotation = 0;
        max_scr = 0;
        for R=ROT

            Contour_candidate = RotateScaleOffsetContour(ContourRef, R, Scale, dx, dy);
            score = ContourDistByArea(Contour_candidate, CA.Contour, Flow.DebugPlotAdvEn);

            if (score > max_scr)
                max_scr = score;
                Rotation = R;
            end

            if (Flow.DebugPlotEn)
                SCR(IND) = score;
                IND = IND + 1;
            end
        end
    end

    %% Pack ME result:
    ME.dX        = dx;
    ME.dY        = dy;
    ME.Rotation  = Rotation;
    ME.Scale     = Scale;
end

ME.ScaleEn = 0;


%-------------------------------------------------------------------------------------------
%% Debug:
%-------------------------------------------------------------------------------------------
if ~Flow.ParentFE
    DebugMotionEstimation(ME, CA, ContourRef, SCR, prevParams, Flow);
end

%-------------------------------------------------------------------------------------------
%% Update Prevs:
if ~Flow.ParentFE
    prevParams.dX  = ME.dX;
    prevParams.dY  = ME.dY;
    prevParams.Rot = ME.Rotation;
    prevParams.Scl = ME.Scale;
end
