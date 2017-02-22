function DebugMotionEstimation(ME, CA, ContourRef, SCR, prevParams, Flow)

persistent h
persistent vidObjDebugWR
persistent CeFe_RotDist

if (Flow.FrameIdx==Flow.StartAtFrm)
    CeFe_RotDist = zeros(1,Flow.StopAtFrm);
    return;
end

%------------------------------------------------------------------------------------------
%% Extract parameters:
Contour = CA.Contour;

dx       = ME.dX;
dy       = ME.dY;
Scale    = ME.Scale;
Rotation = ME.Rotation;

diffMERotation = Rotation - prevParams.Rot;
diffMEScale    = Scale / prevParams.Scl;
diffMEdx       = dx - prevParams.dX;
diffMEdy       = dy - prevParams.dY;

CA_dist = abs(CA.LinParams(1) - diffMERotation);
CA_dist = min(CA_dist, 2*pi - CA_dist);
CeFe_RotDist(1,Flow.FrameIdx:end) = repmat(CA_dist,1,Flow.StopAtFrm-Flow.FrameIdx+1);


%------------------------------------------------------------------------------------------
%% Verbose:
if (Flow.DebugVerboseEn)
    fprintf('       \t[ME]    R=%.3f (%.3f, CA_dist=%.3f), S=%.2f (%.2f), dX=%d (%d), dY=%d (%d)\n', ...
             Rotation, diffMERotation, CA_dist, Scale, diffMEScale, dx, diffMEdx, dy, diffMEdy); 
end

%------------------------------------------------------------------------------------------
%% Plot:
if (Flow.DebugPlotEn)
    
    if (Flow.FrameIdx==Flow.StartAtFrm+1)
        h = figure('Name','ME Debug','Units','normalized','Position',[0 0 1 1]);
        if (Flow.VideoEn)
            vidObjDebugWR = VideoWriter(fullfile(Flow.results_dir,strcat(Flow.VideoName,'ME_Dbg')));  
            vidObjDebugWR.FrameRate = Flow.fps;
            open(vidObjDebugWR);
            set(h, 'Resize', 'off');
        end
    else
        figure(h);
    end
    
    ContourME = RotateScaleOffsetContour(ContourRef, Rotation, Scale, dx, dy);
    
    SizeX = max([max(Contour(1,:)), max(ContourME(2,:))]) + 10;
    SizeY = max([max(Contour(2,:)), max(ContourME(2,:))]) + 10;
    Image_Size = [SizeY,SizeX];
       
    subplot(2,2,1);
    imshow(zeros(Image_Size));
    hold on;
    plot(ContourRef(1,:),ContourRef(2,:),'--y');
    plot(Contour(1,:),Contour(2,:),'-g');
    plot(ContourME(1,:),ContourME(2,:),'-r');
    hold off;
    legend('Prev','CA','ME','Location','Best');
    title(sprintf('Frame %d: ME R=%.3f (%.3f)',Flow.FrameIdx, Rotation, diffMERotation));

    subplot(2,2,2);
    ROT = linspace(-pi,pi,360);
    plot(ROT,SCR);
    xlabel('Rotation');
    ylabel('Score');
    title('Score (AreaSim)');

    subplot(2,2,3);
    plot(sqrt(sum(ContourME-Contour).^2),'r');
    xlabel('Point');
    ylabel('Distance');
    title('Auclidean Distance');
    
    subplot(2,2,4);
    xlabel('Frame');
    plot(CeFe_RotDist); 
    ylabel('CE/FE Rotation distance');
    title('CE/FE Rotation distance');
    
    if (Flow.VideoEn)
        F = getframe(h);
        writeVideo(vidObjDebugWR,F);    
   
        if (Flow.StopAtFrm == Flow.FrameIdx)
            close(vidObjDebugWR);
        end
    end    
end
