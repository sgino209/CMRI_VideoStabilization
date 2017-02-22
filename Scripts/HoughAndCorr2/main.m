clear all; close all; diary off; clc;
dbstop if error
addpath('.\Auxileries');
tic
StopAtFrm = 41;

%------------------------------------------------------------------------------------------------------------
%% Retrieve input video:
filename = 'DICOMDIR';
if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
    pathname = 'D:\ShaharG\DataBase\MRI\Shiba_MRI_Heart_12.08.12\';
else
    pathname = '..\..\..\..\HDRCompanding\DataBase\MRI\Shiba_MRI_Heart_12.08.12\';
end
% [filename, pathname] = uigetfile( ...
%     {  'DICOMDIR', 'Medical video (DICOMDIR)'; ...
%     '*.avi;*.mpg;*.wmv;*.asf;*.asx','Standard video'; ...
%     '*.mp4 ; *.m4v',  'Windows7 only (*.mp4 , *.m4v)'}, ...
%     'Pick a file', '..\..\');

[infoDB, medicalFile, nFrames] = MedicalVideoInit(pathname, filename);

%------------------------------------------------------------------------------------------------------------
%% Open figure handler:
h = figure('Name','CMRI_Stabilizer1','Units','normalized','Position',[0 0 1 1]);
vidObjWR = VideoWriter('.\CMRI_result'));
vidObjWR.FrameRate = 5;
open(vidObjWR);
set(h, 'Resize', 'off');

%------------------------------------------------------------------------------------------------------------
%% Frames analyze (core):             
FrameIdx = 1;
StopAtFrm = min([StopAtFrm,nFrames]);
offset1_prev = [0 0];
offset2_prev = [0 0];
while (1)
    
    %------------------------------------------------------------------------------------------
    %% Read frame:
    J  = dicomread(fullfile(pathname,medicalFile));
    infoIM = dicominfo(fullfile(pathname,medicalFile));
   
    %------------------------------------------------------------------------------------------
    %% Pre Process (norm, rgb2gray, smooth):
    [I,~] = PreProcess(J);

    %% ROI selection:
    if (FrameIdx == 1)
        h1 = figure('Name','ROI Selection','Units','normalized','Position',[0 0 1 1]);
        imshow(I,[]);
        h2=msgbox('Please select ROI (heart bottom line)', 'ROI Selection');
        uiwait(h2);
        h3 = imrect;
        rect = wait(h3);
        close(h1);
        clear('h1','h2','h3');
    end
    
    %------------------------------------------------------------------------------------------
    %% Generate 2 channels (brightness & texture):
    I_CLAHE = adapthisteq(I);
    
    I_LF = CalculateLF(I_CLAHE);
    
    I_ROI = imcrop(I_CLAHE,rect);
    I_ROI_LF = imcrop(I_LF,rect);
    
    if (FrameIdx == 1)
        I_ROI_prev = I_ROI;
        I_ROI_LF_prev = I_ROI_LF;
    end
    
    %------------------------------------------------------------------------------------------
    %% Estimate Rotation, hough based:
    % Generate BW edge images for ROI:
    I_ROI_BW1 = edge(I_ROI,'canny');
    I_ROI_BW2 = edge(I_ROI_LF,'canny');
    
    % Calculate Hough transform:
    [H1,T1,R1] = hough(I_ROI_BW1);
    [H2,T2,R2] = hough(I_ROI_BW2);
    

    if (FrameIdx == 1)
        % Calculate peaks:
        P1 = houghpeaks(H1,5);
        P2 = houghpeaks(H2,5);
    
        x1 = T1(P1(1,2));
        x2 = T2(P2(1,2));
    else
        hough_vec1 = max(H1);
        hough_vec2 = max(H2);
        
        [~,imax1] = max(hough_vec1(rot1_prev-5:rot1_prev+5));
        [~,imax2] = max(hough_vec2(rot2_prev-5:rot2_prev+5));
        
        x1 = T1(imax1 + rot1_prev - 6);
        x2 = T2(imax2 + rot2_prev - 6);
    end
    
    Rotation1 = x1 + 90;
    Rotation2 = x2 + 90;

    if Rotation1>90
        Rot1 = 180-Rotation1;
    else
        Rot1 = Rotation1;
    end

    if Rotation2>90
        Rot2 = 180-Rotation2;
    else
        Rot2 = Rotation2;
    end
    
    %------------------------------------------------------------------------------------------
    %% Estimate Offset, 2D-correlation based:
    C1 = xcorr2(I_ROI,I_ROI_prev); [~,imax1] = max(abs(C1(:))); [y1,x1]=ind2sub(size(C1),imax1(1));
    offset1 = [y1-size(I_ROI,1) , x1-size(I_ROI,2)] + offset1_prev;
    dx1 = offset1(2);
    dy1 = offset1(1);

    C2 = xcorr2(I_ROI_LF,I_ROI_LF_prev); [~,imax2] = max(abs(C2(:))); [y2,x2]=ind2sub(size(C2),imax2(1));
    offset2 = [y2-size(I_ROI_LF,1) , x2-size(I_ROI_LF,2)] + offset2_prev;
    dx2 = offset2(2);
    dy2 = offset2(1);
    
    %------------------------------------------------------------------------------------------
    %% Stabilize frame (offset fix):
    I_stable_pre1 = I;
    if (dx1>0)
        I_stable_pre1 = [ I_stable_pre1(:,dx1+1:end,:) , ...
                         zeros(size(I_stable_pre1,1),dx1,size(I_stable_pre1,3)) ];
    elseif (dx1<0)
        dx1 = abs(dx1);
        I_stable_pre1 = [ zeros(size(I_stable_pre1,1),dx1,size(I_stable_pre1,3)) , ...
                         I_stable_pre(:,1:end-dx1,:) ];
    end

    if (dy1>0)
        I_stable_pre1 = [ I_stable_pre1(dy1+1:end,:,:)                          ; ...
                         zeros(dy1,size(I_stable_pre1,2),size(I_stable_pre1,3)) ];
    elseif (dy1<0)
        dy1 = abs(dy1);
        I_stable_pre1 = [ zeros(dy1,size(I_stable_pre1,2),size(I_stable_pre1,3)) ; ...
                         I_stable_pre1(1:end-dy1,:,:)                           ];
    end
    
    %------------------
    
    I_stable_pre2 = I;
    if (dx2>0)
        I_stable_pre2 = [ I_stable_pre2(:,dx2+1:end,:) , ...
                         zeros(size(I_stable_pre2,1),dx2,size(I_stable_pre2,3)) ];
    elseif (dx2<0)
        dx2 = abs(dx2);
        I_stable_pre2 = [ zeros(size(I_stable_pre2,1),dx2,size(I_stable_pre2,3)) , ...
                         I_stable_pre2(:,1:end-dx2,:) ];
    end

    if (dy2>0)
        I_stable_pre2 = [ I_stable_pre2(dy2+1:end,:,:)                          ; ...
                         zeros(dy2,size(I_stable_pre2,2),size(I_stable_pre2,3)) ];
    elseif (dy2<0)
        dy2 = abs(dy2);
        I_stable_pre2 = [ zeros(dy2,size(I_stable_pre2,2),size(I_stable_pre2,3)) ; ...
                         I_stable_pre2(1:end-dy2,:,:)                           ];
    end
    
    %------------------------------------------------------------------------------------------
    %% Stabilize frame (rotation fix):
    [X,Y] = meshgrid(1:size(I,2), 1:size(I,1));

    center_shift1 = [size(I,2)/2 - dx1, size(I,1)/2 - dy1];
    center_shift2 = [size(I,2)/2 - dx2, size(I,1)/2 - dy2];

    X_shift1 = X - center_shift1(1);
    Y_shift1 = Y - center_shift1(2);

    X_shift2 = X - center_shift2(1);
    Y_shift2 = Y - center_shift2(2);
    
    Rot1_rad = deg2rad(Rot1);
    Rot2_rad = deg2rad(Rot2);
    
    Xi1 = center_shift1(1) + cos(Rot1_rad)*X_shift1 - sin(Rot1_rad)*Y_shift1;
    Yi1 = center_shift1(2) + sin(Rot1_rad)*X_shift1 + cos(Rot1_rad)*Y_shift1;

    Xi2 = center_shift2(1) + cos(Rot2_rad)*X_shift2 - sin(Rot2_rad)*Y_shift2;
    Yi2 = center_shift2(2) + sin(Rot2_rad)*X_shift2 + cos(Rot2_rad)*Y_shift2;
    
    I_stable1 = interp2(X, Y, I_stable_pre1, Xi1, Yi1, 'linear');
    I_stable1(isnan(I_stable1))=0;
    
    I_stable2 = interp2(X, Y, I_stable_pre2, Xi2, Yi2, 'linear');
    I_stable2(isnan(I_stable2))=0;
    
    %------------------------------------------------------------------------------------------
    %% Plot results:
    figure(h);
    
    subplot(2,3,1);
    imshow(I,[]);
    title(sprintf('Input (Frame %d/%d)',FrameIdx,StopAtFrm));
    
    %------------------
    
    subplot(2,3,2);
    imshow(I_stable1,[]);
    title('Output (BR based)');
    
    %------------------
    
    subplot(2,3,3);
    imshow(I_stable2,[]);
    title('Output (LF based)');
    
    %------------------
    
    subplot(2,3,4);
    imshow(I_LF,[]);
    title('LF[Input]');

    %------------------
    
    subplot(2,3,5);
    imshow(I_ROI,[]);
    title(sprintf('ROI in Brightness (Rotation=%.2f deg, Offset=[%d,%d])',Rotation1,offset1));
    
    % Hough Highlights:
    lines1 = houghlines(I_ROI_BW1,T1,R1,P1,'FillGap',20,'MinLength',10);
    hold on
    max_len1 = 0;
    for k = 1:length(lines1)
        xy1 = [lines1(k).point1; lines1(k).point2];
       
        tx1 = round( linspace(xy1(1,1),xy1(2,1),100) );
        ty1 = round( interp1(xy1(:,1),xy1(:,2),tx1,'linear') );
        
        Imask1=zeros(size(I_CLAHE)); Imask1(sub2ind(size(Imask1),tx1,ty1))=1;
        
        SampleVal = sum(sum(Imask1 .* I_CLAHE));
        
        if (lines1(k).theta == Rotation1-90)
            plot(xy1(:,1),xy1(:,2),'LineWidth',2,'Color','red');
        else
            plot(xy1(:,1),xy1(:,2),'LineWidth',2,'Color','green');
        end

        % Plot beginnings and ends of lines
        plot(xy1(1,1),xy1(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy1(2,1),xy1(2,2),'x','LineWidth',2,'Color','cyan');

        % Determine the endpoints of the longest line segment
        len1 = norm(lines1(k).point1 - lines1(k).point2);
        if ( len1 > max_len1)
            max_len1 = len1;
            xy_long1 = xy1;
        end
    end
    plot(xy_long1(:,1),xy_long1(:,2),'LineWidth',2,'Color','blue');

    %------------------
    
    subplot(2,3,6);
    imshow(I_ROI_LF,[]);
    title(sprintf('ROI in Texture/LF (Rotation=%.2f deg, Offset=[%d,%d])',Rotation2,offset2));
    
    % Hough Highlights:
    lines2 = houghlines(I_ROI_BW2,T2,R2,P2,'FillGap',20,'MinLength',10);
    hold on
    max_len2 = 0;
    for k = 1:length(lines2)
        xy2 = [lines2(k).point1; lines2(k).point2];

        if lines2(k).theta == Rotation2-90
            plot(xy2(:,1),xy2(:,2),'LineWidth',2,'Color','red');
        else
            plot(xy2(:,1),xy2(:,2),'LineWidth',2,'Color','green');
        end

        % Plot beginnings and ends of lines
        plot(xy2(1,1),xy2(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy2(2,1),xy2(2,2),'x','LineWidth',2,'Color','cyan');

        % Determine the endpoints of the longest line segment
        len2 = norm(lines2(k).point1 - lines2(k).point2);
        if ( len2 > max_len2)
            max_len2 = len2;
            xy_long2 = xy2;
        end
    end
    plot(xy_long2(:,1),xy_long2(:,2),'LineWidth',2,'Color','blue');
    
    %------------------------------------------------------------------------------------------
    %% Save results to video files:
    F = getframe(h);
    writeVideo(vidObjWR,F);
            
    %------------------------------------------------------------------------------------------
    %% Retrieve next image:
    [medicalFile,wa] = GetNextDCM(infoDB, infoIM);
      
    %% Break contdition:
    if ((wa<0) || (FrameIdx == StopAtFrm))
        break
    end   

    %% Update loop parameters:
    FrameIdx = FrameIdx + 1;
    
    I_ROI_prev = I_ROI;
    I_ROI_LF_prev = I_ROI_LF;
    
    offset1_prev = offset1;
    offset2_prev = offset2;
    rot1_prev = P1(1,2);
    rot2_prev = P2(1,2);
end

%------------------------------------------------------------------------------------------------------------
%% Close video handlers:
close(vidObjWR);
    
runtime = toc;
fprintf('Completed!\n');
fprintf('Runtime = %.02f sec\n', runtime);
fprintf('Average frame time = %.02f sec\n', runtime/StopAtFrm);