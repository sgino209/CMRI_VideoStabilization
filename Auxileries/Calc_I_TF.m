function I_curr_TF = Calc_I_TF(prev2, prev, curr, Flow)

persistent h
persistent vidObjDebugWR

%% Transform current frame to "prev2 domain":
CA.Flush = 0;
CA.BypassFE = 0;
CA.LinParams = [0 1 0 0];

DebugPlotEn = Flow.DebugPlotEn;

Flow.DebugPlotEn = 0;
Flow.ParentFE = 1;

CA.Contour = prev.C;
ME1 = MotionEstimation(prev2.C, CA, Flow);
ME1.ScaleEn  = 1;
ME1.ScaleRef = size(prev.I);
I_prev_prev2 = MotionCompansation(prev.I, prev.C, ME1, Flow);

CA.Contour = curr.C;
ME2 = MotionEstimation(prev2.C, CA, Flow);
ME2.ScaleEn  = 1;
ME2.ScaleRef = size(curr.I);
I_curr_prev2 = MotionCompansation(curr.I, curr.C, ME2, Flow);

Flow.DebugPlotEn = DebugPlotEn;

%------------------------------------------------------------------------------------------
%% Temporal Filtering (TF) calculation (at "prev2 domain"):     %% TBD:  Replace global blending with
I_curr_TF_prev2 = (I_curr_prev2 + I_prev_prev2 + prev2.I) / 3;  %%       Local blending according to
                                                                %%       a local Motion map.
%------------------------------------------------------------------------------------------
%% Transform TF back to "current-frame" domain:
ME3.Rotation = -ME2.Rotation;
ME3.Scale    = 1/ME2.Scale;
ME3.dX       = -ME2.dX;
ME3.dY       = -ME2.dY;
ME3.ScaleEn  = 1;
ME3.ScaleRef = size(curr.I);

Contour_TF = RotateScaleOffsetContour(curr.C, ME3.Rotation, ME3.Scale, ME3.dX, ME3.dY);

I_curr_TF = MotionCompansation(I_curr_TF_prev2, Contour_TF, ME3, Flow);


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotEn)
    
    if (Flow.FrameIdx == Flow.StartAtFrm+1)
        h = figure('Name','FE Debug','Units','normalized','Position',[0 0 1 1]);
        if (Flow.VideoEn)
            vidObjDebugWR = VideoWriter(fullfile(Flow.results_dir,strcat(Flow.VideoName,'FE_Dbg')));
            vidObjDebugWR.FrameRate = Flow.fps;
            open(vidObjDebugWR);
            set(h, 'Resize', 'off');
        end
    else
        figure(h);
    end
    
    h1=subplot(2,2,1);
    imshow(curr.I);
    hold on;
    plot(curr.C(1,:),curr.C(2,:),'--r');
    hold off;
    title(sprintf('ROI contour (Frame %d)',Flow.FrameIdx));
    
    h2=subplot(2,2,2);
    imshow(I_curr_TF);
    hold on;
    plot(curr.C(1,:),curr.C(2,:),'--r');
    hold off;
    title('ROI contour on TF image');
    
    I1(:,:,1) = curr.I;
    I1(:,:,2) = prev.I;
    I1(:,:,3) = prev2.I;
    h3 = subplot(2,2,3);
    imshow(I1);
    title('3 last images before TF: [R,G,B]=[t,t-1,t-2]');
    
    I2(:,:,1) = I_curr_prev2;
    I2(:,:,2) = I_prev_prev2;
    I2(:,:,3) = prev2.I;
    h4 = subplot(2,2,4);
    imshow(I2);
    title('3 last images after TF: [R,G,B]=[t,t-1,t-2]');
    
    linkaxes([h1 h2 h3 h4]);
    
    drawnow;
    
    if (Flow.VideoEn)
        F = getframe(h);
        writeVideo(vidObjDebugWR,F);    
   
        if (Flow.StopAtFrm == Flow.FrameIdx)
            close(vidObjDebugWR);
        end
    end
end