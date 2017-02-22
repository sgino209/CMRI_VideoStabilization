clear all; close all; clc;
tic

%-------------------------------------------------------------------------------------------------------
%% User interface:
PathName = uigetdir('../../Results/Medical/comparison');

%% FileNames:
FileName1 = 'Input.avi';
FileName2 = 'LKT.avi';
FileName3 = 'TemplateMatching.avi';
FileName4 = 'Youtube.avi';
FileName5 = 'Adobe_PremierePro7.avi';
FileName6 = 'VirtualDub_Deshaker3.avi';
FileName7 = 'Ours_MSE.avi';
FileName8 = 'Ours_SSIM.avi';

InputVideo1 = fullfile(PathName,FileName1);
InputVideo2 = fullfile(PathName,FileName2);
InputVideo3 = fullfile(PathName,FileName3);
InputVideo4 = fullfile(PathName,FileName4);
InputVideo5 = fullfile(PathName,FileName5);
InputVideo6 = fullfile(PathName,FileName6);
InputVideo7 = fullfile(PathName,FileName7);
InputVideo8 = fullfile(PathName,FileName8);

%-------------------------------------------------------------------------------------------------------
%% System Objects init.:
videoFileReader1 = vision.VideoFileReader(InputVideo1);
videoFileReader2 = vision.VideoFileReader(InputVideo2);
videoFileReader3 = vision.VideoFileReader(InputVideo3);
videoFileReader4 = vision.VideoFileReader(InputVideo4);
videoFileReader5 = vision.VideoFileReader(InputVideo5);
videoFileReader6 = vision.VideoFileReader(InputVideo6);
videoFileReader7 = vision.VideoFileReader(InputVideo7);
videoFileReader8 = vision.VideoFileReader(InputVideo8);

videoFileWriter  = vision.VideoFileWriter('Compare2x4.avi','FrameRate',videoFileReader1.info.VideoFrameRate);
videoFileWriter.VideoCompressor = 'MJPEG Compressor';

while ( ~isDone(videoFileReader1) && ~isDone(videoFileReader2) && ~isDone(videoFileReader3) && ~isDone(videoFileReader4) && ...
        ~isDone(videoFileReader5) && ~isDone(videoFileReader6) && ~isDone(videoFileReader7) && ~isDone(videoFileReader8) )
    J1 = step(videoFileReader1);
    J2 = step(videoFileReader2);
    J3 = step(videoFileReader3);
    J4 = step(videoFileReader4);
    J5 = step(videoFileReader5);
    J6 = step(videoFileReader6);
    J7 = step(videoFileReader7);
    J8 = step(videoFileReader8);
    
    I1_pre = J1;
    I2_pre = J2(:,round(size(J2,2)/2):end,:);
    I3_pre = J3(:,round(size(J3,2)/2):end,:);
    I4_pre = J4;
    I5_pre = J5;
    I6_pre = J6;
    I7_pre = J7(:,round(size(J7,2)/2):end,:);
    I8_pre = J8(:,round(size(J8,2)/2):end,:);
    
    I1 = imresize(I1_pre, [200,300]);
    I2 = imresize(I2_pre, [200,300]);
    I3 = imresize(I3_pre, [200,300]);
    I4 = imresize(I4_pre, [200,300]);
    I5 = imresize(I5_pre, [200,300]);
    I6 = imresize(I6_pre, [200,300]);
    I7 = imresize(I7_pre, [200,300]);
    I8 = imresize(I8_pre, [200,300]);
    
    out = [ I1 , I2 , I3 , I4 ; I5 , I6 , I7 , I8 ];
    
    step(videoFileWriter, out);
end

release(videoFileReader1);
release(videoFileReader2);
release(videoFileReader3);
release(videoFileReader4);
release(videoFileReader5);
release(videoFileReader6);
release(videoFileReader7);
release(videoFileReader8);
release(videoFileWriter);

fprintf('Completed!\nRuntime = %.02f sec\n', toc);