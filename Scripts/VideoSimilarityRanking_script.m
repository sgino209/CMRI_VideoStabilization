close all; clear all; clc;
tic

%----------------------------------------------------------------------------------
%% User parameters:
ZoomIn = 0;
CompMode = '1x2';   % Either: 'Manual', '2x4' or '1x2'
CompPath = 'C:\Users\sg24\Downloads\Research\Tracking\Results\Medical\comparison';

%----------------------------------------------------------------------------------
%% Rects:
switch CompMode
    case 'Manual'
                Rects = [];
        
    case '1x2'
                Rects = [  0,   0, 255, 255 ; ... % Left (input)
                         255,   0, 255, 255 ];    % Right (input)
                
                listing = dir(CompPath);
                N = length(listing);
        
    case '2x4'
                Rects = [  9,  50, 270, 275 ; ... % A
                         310,  50, 270, 275 ; ... % B
                         617,  50, 270, 275 ; ... % C
                         917,  50, 270, 275 ; ... % D
                           9, 402, 270, 275 ; ... % E
                         310, 402, 270, 275 ; ... % F
                         617, 402, 270, 275 ; ... % G
                         917, 402, 270, 275 ];    % H
        
    otherwise
        fprintf('Unknown mode: %s',CompMode);
end
         
%----------------------------------------------------------------------------------
%% Manual mode
if strcmp(CompMode,'Manual')
    [FileName,PathName] = uigetfile(fullfile(CompPath,'*.avi'));
    VideoFile = fullfile(PathName,FileName);
    SimRanks = VideoSimilarityRanking(VideoFile,Rects,0);
    fprintf('meanITF = %.4f dB, meanSSIM = %.4f\n', SimRanks.meanITF, SimRanks.meanSSIM);
else

%----------------------------------------------------------------------------------
%% 1x2 or 2x4 modes:
    listing = dir(CompPath);
    N = length(listing);    
    for n=1:N

        FolderName = listing(n).name;

        if strcmp(FolderName,'.') || strcmp(FolderName,'..')
            continue
        end

        fprintf('Folder=%s\n', FolderName);

        VideoFile_pre = fullfile(CompPath,FolderName,[CompMode,'_Compare']);
        VideoFiles = ls(fullfile(VideoFile_pre,'*.avi'));
        L = size(VideoFiles,1);
        for l=1:L
            VideoFile = fullfile(VideoFile_pre,VideoFiles(l,:));
            fprintf('%s:\n',VideoFiles(l,:));

            K = size(Rects,1);
            for k = 1:K
                if ZoomIn
                    x = [Rects(k,1)+0.25*Rects(k,3), Rects(k,2)+0.25*Rects(k,4), Rects(k,3)/2, Rects(k,4)/2]; %#ok<UNRCH>
                    SimRanks = VideoSimilarityRanking(VideoFile,x,0);
                else
                    SimRanks = VideoSimilarityRanking(VideoFile,Rects(k,:),0);
                end
                fprintf('%d): meanITF = %.4f dB, meanSSIM = %.4f\n', k, SimRanks.meanITF, SimRanks.meanSSIM);
            end
        end
    end
end

toc

%---------------------------------------------------------------------------------------------------------------
%% Debug:
if (0)
    videoFileReader = vision.VideoFileReader(VideoFile); %#ok<UNRCH>
    I = step(videoFileReader);
    figure; imshow(I); hold on;
    for k=1:8
        x = [Rects(k,1)+0.25*Rects(k,3), Rects(k,2)+0.25*Rects(k,4), Rects(k,3)/2, Rects(k,4)/2];
        rectangle('Position',Rects(k,:),'EdgeColor','red');
        rectangle('Position',x,'EdgeColor','green');
    end
    hold off;
    release(videoFileReader);
end