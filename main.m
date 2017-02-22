clear all; close all; diary off; clc;
dbstop if error
addpath('.\Auxileries');
tic

%------------------------------------------------------------------------------------------------------------
%% Load user parame ters:
[Params, Flow] = include();

%------------------------------------------------------------------------------------------------------------
%% Retrieve input video:
[pathname, filename, uBasepath] = GetVideoFileName(Flow);

if isequal(filename,0)
    return
end

%% Video initialization:
medicalImage = strcmp(filename,'DICOMDIR');

if (medicalImage)
    [infoDB, medicalFile, nFrames] = MedicalVideoInit(pathname, filename, Flow.StartAtFrm);
else
    [vidObjRD, nFrames] = GeneralVideoInit(pathname, filename);
end

%------------------------------------------------------------------------------------------------------------
%% Open figure handler:
if (medicalImage)
    Flow.fps = 5;
else
    Flow.fps = vidObjRD.FrameRate;
end
[h, vidObjWR1, vidObjWR2, Flow.results_dir] = FlowInit(Flow);
Flow.ParentFE = 0;

%------------------------------------------------------------------------------------------------------------
%% Frames analyze (core):             
Flow.FrameIdx = Flow.StartAtFrm;
Flow.StopAtFrm = min([Flow.StopAtFrm,nFrames]);
while (1)
    
    %------------------------------------------------------------------------------------------
    % Read frame:
    if (medicalImage)
        J  = dicomread(fullfile(pathname,medicalFile));
        infoIM = dicominfo(fullfile(pathname,medicalFile));
    else
        J = read(vidObjRD, Flow.FrameIdx-Flow.StartAtFrm+1);
    end
    
    %------------------------------------------------------------------------------------------
    % Pre Process (norm, rgb2gray, smooth):
    [I,J] = PreProcess(J);
    
    %------------------------------------------------------------------------------------------        
    % First frame initializations:
    if (Flow.FrameIdx == Flow.StartAtFrm)
        Contour = GetInitialContour(Flow, Params, h, J);
    end
    
    %------------------------------------------------------------------------------------------
    % Contour Adjustment (CA):
    CA = ContourAdjust(I, Contour, Params, Flow);
        
    %------------------------------------------------------------------------------------------
    % Motion Estimation (ME):
    ME = MotionEstimation(CA.ContourRef, CA, Flow);

    %------------------------------------------------------------------------------------------
    % Motion Compansation (MC):
    I_stable = MotionCompansation(J, CA.Contour, ME, Flow);
    
	%------------------------------------------------------------------------------------------
    % Plot frame:
    if (Flow.PlotEn)
        UpdatePlot(h, J, I_stable, Contour, CA, ME, Flow);
    end
    
    %------------------------------------------------------------------------------------------
    % Save frame to video file:
    if (Flow.VideoEn)
        UpdateVideo(h, J, I_stable, vidObjWR1, vidObjWR2);
        
        if (~Flow.DebugVerboseEn && ~mod(Flow.FrameIdx,10))
            fprintf('[Video] frame %d\n',Flow.FrameIdx);
        end
    end
    
    %------------------------------------------------------------------------------------------
    % Prepare for next frame analysis:

    % Retrieve next image:
    VideoComplete = 0;
    if (medicalImage)
        [medicalFile,wa] = GetNextDCM(infoDB, infoIM);
        VideoComplete = wa<0;
    end
          
    % Break contdition:
    if (VideoComplete || (Flow.FrameIdx == Flow.StopAtFrm))
        break
    end   

    % Update loop parameters:
    Contour = CA.Contour;
    Flow.FrameIdx = Flow.FrameIdx + 1;
end

%------------------------------------------------------------------------------------------------------------
%% Close video handler:
if (Flow.VideoEn)
    close(vidObjWR1);
    close(vidObjWR2);
end

runtime = toc;
fprintf('Completed!\n');
fprintf('Runtime = %.02f sec\n', runtime);
fprintf('Average frame time = %.02f sec\n', runtime/Flow.StopAtFrm);
close all;
diary off
