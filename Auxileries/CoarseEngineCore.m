function scoreBoard = CoarseEngineCore(Channels_curr, Contour, target_samples, Params, Flow)

N = length(Contour);

%------------------------------------------------------------------------------------------
%% Init ScoreBoard:
scoreBoard = zeros(length(Params.Rotate), length(Params.Scale), ...
                   length(Params.Offset), length(Params.Offset), 2);

%------------------------------------------------------------------------------------------
%% Loop:
for R=Params.Rotate
    for S=Params.Scale
        for dx=Params.Offset
            for dy=Params.Offset
                
                %% Generate a candidate contour:
                ConCandidate = RotateScaleOffsetContour(Contour, R, S, dx, dy);
               
                %% Contour matching (find best ROI shape):
                [score_Con,~] = CalcSpacialConScore(0, Channels_curr.ch1, ConCandidate, 3*ones(1,N), Params, Flow);
                
                %% Region matching (similarity matching, importance-sampling by texture):
                src_Reg_samples = SampleImageInsideContour(Channels_curr, ConCandidate, Flow);
                
                RegionErr = CalcRegionErr(target_samples, src_Reg_samples, ConCandidate, R, S, dx, dy, Flow);
                
                score_Reg = -RegionErr;
                
                %% Update ScoreBoard:
                scoreBoard(Params.Rotate==R,  Params.Scale==S, ...
                           Params.Offset==dx, Params.Offset==dy, :) = [score_Con ; score_Reg];
            end
        end
    end
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    
    figure('Name', 'CE_Core debug','Units','normalized','Position',[0 0 1 1]);
    
    [R_,S_,dx_,dy_] = ind2sub(size(scoreBoard(:,:,:,:,1)), find(scoreBoard == max(max(max(max(scoreBoard(:,:,:,:,1)))))));

    ConCandidate = RotateScaleOffsetContour(Contour, Params.Rotate(R_), Params.Scale(S_), Params.Offset(dx_), Params.Offset(dy_));
    
    [~,score_Con_Whts] = CalcSpacialConScore(0, Channels_curr.ch1, ConCandidate, 3*ones(1,N), Params, Flow);    

    src_Reg_samples = SampleImageInsideContour(Channels_curr, ConCandidate, Flow);
    
    subplot(2,2,1);
    imshow(Channels_curr.ch1,[]);
    hold on;
    plot(ConCandidate(1,:),ConCandidate(2,:),'go-');
    C2 = RotateScaleOffsetContour(ConCandidate, 0, 0.8, 0, 0);
    C3 = RotateScaleOffsetContour(ConCandidate, 0, 1.2, 0, 0);    
    plot(C2(1,:),C2(2,:),'r-');
    plot(C3(1,:),C3(2,:),'r-');
    hold off;
    title('CH1, Contour');
    zoom(2);
    
    subplot(2,2,2);
    bar(score_Con_Whts); xlim([0, length(score_Con_Whts)]);
    title('CH1, Contour score');
    
    h1=subplot(2,2,3);
    imshow( imfuse(src_Reg_samples.ch1, target_samples.ch1, ...         % SRC = red
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]) );  % TGT = green
    title('CH1, Region');                                               % Intersection = yellow
    
    h2=subplot(2,2,4);
    imshow( imfuse(src_Reg_samples.ch2, target_samples.ch2, ...         % SRC = red
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]) );  % TGT = green
    title('CH2, Region');                                               % Intersection = yellow
    
    linkaxes([h1 h2]);
    zoom(1.5);
end