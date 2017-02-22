function DebugContourAdjust(Channels_curr, Winner, SB, flush, Score_Weights_ch, EdgesDiffRatio, CA, Flow, Params)
persistent h
persistent vidObjDebugWR

%---------------------------------------------------------------
%% Debug (verbosity):
if (Flow.DebugVerboseEn)
    fprintf('      \t[CA]    EdgesDiffRatio=%.2f , RegInfo=%.2f\n', EdgesDiffRatio, entropy(Channels_curr.ch2));
    
    if (Winner.updated)
        fprintf('                --> Updated (CE)!\n');
    end
    
    if (flush.flushCond1 || flush.flushCond2)
        fprintf('                --> Flushed (%d,%d)!\n', flush.flushCond1, flush.flushCond2);
    end
        
end

%---------------------------------------------------------------
%% Debug (plotting):
if (Flow.DebugPlotEn)
	
    if (Flow.FrameIdx == Flow.StartAtFrm+1)
        h = figure('Name','CA Debug','Units','normalized','Position',[0 0 1 1]);
        if (Flow.VideoEn)
            vidObjDebugWR = VideoWriter(fullfile(Flow.results_dir,strcat(Flow.VideoName,'CA_Dbg')));  
            vidObjDebugWR.FrameRate = Flow.fps;
            open(vidObjDebugWR);
            set(h, 'Resize', 'off');
        end
    else
        figure(h);
    end
    
    %------------------------------------------------------------------------------------------
    
    h1=subplot(2,3,1);  subimage(Channels_curr.ch1);  
    title(sprintf('CH1 (#%03d)',Flow.FrameIdx)); zoom(1.5);
   
    %------------------------------------------------------------------------------------------
    
    h2=subplot(2,3,2);  subimage(Channels_curr.ch2);  
    title('CH2 (Texture)'); zoom(1.5);  linkaxes([h1 h2]);
   
    %------------------------------------------------------------------------------------------
    
    subplot(2,3,3);
    subimage(Channels_curr.ch1);
    hold on;
    ContourAdj_shrink = RotateScaleOffsetContour(Winner.ContourAdj, 0, Params.FE_Shrink, 0, 0);
    ContourAdj_expand = RotateScaleOffsetContour(Winner.ContourAdj, 0, Params.FE_Expand, 0, 0);
    plot(Winner.ContourAdj(1,:), Winner.ContourAdj(2,:), '-r');
    plot(Winner.ContourAdjNL(1,:), Winner.ContourAdjNL(2,:), '-g');
    plot(ContourAdj_shrink(1,:), ContourAdj_shrink(2,:), '-b');
    plot(ContourAdj_expand(1,:), ContourAdj_expand(2,:), '-b');
    hold off;
    title(sprintf('CE=%d, FE=%d',Winner.updated,~CA.BypassFE));
    if (Flow.DemoScheme == 1)
        zoom(1.5);
    end
    
    %------------------------------------------------------------------------------------------
    
    A = zeros(size(Channels_curr.ch1));
    A(sub2ind(size(A),CA.Contour(2,:),CA.Contour(1,:))) = Winner.PtsWeight;
    [~,A] = PreProcess(A);
    
    subplot(2,3,4); imshow(filter2(ones(3),im2uint8(A),'same'),[]); title('Contour points weights'); zoom(1.5);
    subplot(2,3,4); subimage(filter2(ones(3),im2uint8(A),'same'),jet); title('Contour points weights'); zoom(1.5);
    
    %------------------------------------------------------------------------------------------
    
    subplot(2,3,5);  bar(Score_Weights_ch,'b');  title('Channels weights');  xlim([1,2]);
    
    %------------------------------------------------------------------------------------------
    
    subplot(2,3,6); 
    if (length(SB.scoreBoardVec) > 10)
        stem(SB.scoreBoardVec(1:10),'b');
    else
        stem(SB.scoreBoardVec,'b');
    end
    title('Normalized scoreBoard (CE)');
    xlim([0,11]);

    %------------------------------------------------------------------------------------------
    
    drawnow;
    
    if (Flow.VideoEn)
        F = getframe(h);
        writeVideo(vidObjDebugWR,F);    
   
        if (Flow.StopAtFrm == Flow.FrameIdx)
            close(vidObjDebugWR);
        end
    end    
end