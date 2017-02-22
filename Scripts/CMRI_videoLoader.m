clear all; close all; diary off; clc;
addpath('..\Auxileries');

[filename, pathname] = uigetfile('*.*', 'Select a DICOMDIR index file');
if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
end

[infoDB, medicalFile, nFrames] = MedicalVideoInit(pathname, filename, 0);

h = figure('Name','CMRI Loader','Units','normalized','Position',[0 0 1 1]);

T = strfind(pathname,'_');
VidName = pathname(T(end)+1:end-1);
vidObjWR = VideoWriter(VidName);
vidObjWR.FrameRate = 5;

open(vidObjWR);

set(h, 'Resize', 'off');

FrameIdx = 1;
while (1)

    J  = dicomread(fullfile(pathname,medicalFile));
    infoIM = dicominfo(fullfile(pathname,medicalFile));

    [I,~] = PreProcess(J);
    
    %I_SORF = CalculateSORF(I);
    %I_LF   = CalculateLF(I);
    
    %[~,I_BLEND] = PreProcess(I_LF + I_SORF/2);
     
    %subplot(2,2,1); 
    imshow(I,[]);    title(sprintf('03.09.13 %s (%d/%d)',VidName,FrameIdx,nFrames));% zoom(2);
    %subplot(2,2,2); imshow(I_SORF,[]);  title('Texture (SORF)');    zoom(2);
    %subplot(2,2,3); imshow(I_LF,[]);    title('Texture (LF)');      zoom(2);
    %subplot(2,2,4); imshow(I_BLEND,[]); title('Texture (SORF/2+LF)'); zoom(2);
        
    F = getframe(h);
    writeVideo(vidObjWR,F);

    [medicalFile,wa] = GetNextDCM(infoDB, infoIM);
    if (wa<0 || FrameIdx > nFrames)
        break
    end
    
    FrameIdx = FrameIdx + 1;
end

close(vidObjWR);

fprintf('Completed!\n');