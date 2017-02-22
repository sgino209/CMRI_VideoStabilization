function SimRanks = VideoSimilarityRanking(Video, rectInit, DebugEn)
% This function gets an input video and returns similarity ranking as output (ITF, GTF, SSIM);
%
% Basic Usage: SimRanks = VideoSimilarityRanking(videoFile,[],0)
%              SimRanks = VideoSimilarityRanking(videoFile,[x,y,w,h],0)
%-------------------------------------------------------------------------

%% Initialization:
videoFileReader = vision.VideoFileReader(Video);

MinITF = Inf;
MaxITF = 0;
SumITF = 0;

MinGTF = Inf;
MaxGTF = 0;
SumGTF = 0;

MinSSIM = Inf;
MaxSSIM = 0;
SumSSIM = 0;

ITF = zeros(1,1000);
GTF = zeros(1,1000);
SSIM = zeros(1,1000);

%-------------------------------------------------------------------------
%% Similarity check:
I_prev = double( im2uint8( rgb2gray( step(videoFileReader) ) ) );

FrameIdx = 1;
while ~isDone(videoFileReader)
 
    %---------------------------------------------------------------
    %% Load next frame:
    I_curr_pre = double( im2uint8( rgb2gray( step(videoFileReader) ) ) );
    
    %---------------------------------------------------------------
    %% Crop:
    if (FrameIdx == 1)
        
        if isempty(rectInit)
            h=figure; imshow(I_prev,[]);
            rect = round(getPosition(imrect));
            close(h);
        else
            rect = rectInit;
        end
        
        I_prev = imcrop(I_prev, rect);
    end
    
    I_curr = imcrop(I_curr_pre, rect);
        
    %---------------------------------------------------------------
    if ~exist('I0','var')
        I0 = I_prev;
    end
    
    %---------------------------------------------------------------
    %% ITF (psnr between successive frames)
    currITF = 20*log10( 255/(norm(I_curr(:)-I_prev(:)+eps)/numel(I_curr)) );

    SumITF = SumITF + currITF;
    
    if (currITF > MaxITF)
        MaxITF = currITF;
    end
    
    if (currITF < MinITF)
        MinITF = currITF;
    end    

    ITF(1,FrameIdx) = currITF;
    
    %---------------------------------------------------------------
    %% GTF (psnr compared to first frame)
    currGTF = 20*log10( 255/(norm(I_curr(:)-I0(:)+eps)/numel(I_curr)) );

    SumGTF = SumGTF + currGTF;
    
    if (currGTF > MaxGTF)
        MaxGTF = currGTF;
    end
    
    if (currGTF < MinGTF)
        MinGTF = currGTF;
    end
    
    GTF(1,FrameIdx) = currGTF;
    
    %---------------------------------------------------------------
    %% SSIM
    currSSIM = ssim(I_curr,I_prev);
    
    SumSSIM = SumSSIM + currSSIM;
    
    if (currSSIM > MaxSSIM)
        MaxSSIM = currSSIM;
    end
    
    if (currSSIM < MinSSIM)
        MinSSIM = currSSIM;
    end
    
    SSIM(1,FrameIdx) = currSSIM;
    
    %---------------------------------------------------------------
    I_prev = I_curr;
    
    FrameIdx = FrameIdx + 1;

end

%-------------------------------------------------------------------------
%% Result packing:
SimRanks.meanITF = SumITF / FrameIdx;
SimRanks.minITF = MinITF;
SimRanks.maxITF = MaxITF;

SimRanks.meanGTF = SumGTF / FrameIdx;
SimRanks.minGTF = MinGTF;
SimRanks.maxGTF = MaxGTF;

SimRanks.meanSSIM = SumSSIM / FrameIdx;
SimRanks.minSSIM = MinSSIM;
SimRanks.maxSSIM = MaxSSIM;

release(videoFileReader);

%-------------------------------------------------------------------------

if (DebugEn)
    ITF = ITF(1,1:FrameIdx-1);
    GTF = SSIM(1,1:FrameIdx-1);
    SSIM = SSIM(1,1:FrameIdx-1);
    
    figure('Name','Video Similarity Ranking','Units','normalized','Position',[0 0 1 1]);
    subplot(3,1,1);  plot(ITF,'r');   xlabel('Frame (#)');  
    title(sprintf('ITF (psnr) - [Mean,Max,Min]=[%.2f,%.2f,%.2f] dB',SimRanks.meanITF,SimRanks.maxITF,SimRanks.minITF));
    subplot(3,1,2);  plot(GTF,'g');   xlabel('Frame (#)');
    title(sprintf('GTF (psnr) - [Mean,Max,Min]=[%.2f,%.2f,%.2f] dB',SimRanks.meanGTF,SimRanks.maxGTF,SimRanks.minGTF));
    subplot(3,1,3);  plot(SSIM,'b');  xlabel('Frame (#)');
    title(sprintf('SSIM (0..1) - [Mean,Max,Min]=[%.4f,%.4f,%.4f]',SimRanks.meanSSIM,SimRanks.maxSSIM,SimRanks.minSSIM));
end