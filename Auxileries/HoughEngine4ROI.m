function [Rotation,LongestLine] = HoughEngine4ROI(I, rect, Flow)

persistent h
persistent vidObjDebugWR
persistent Rot

%------------------------------------------------------------------------------------------
%% Crop ROI:
I_ROI = imcrop(I,rect);

%------------------------------------------------------------------------------------------
%% Generate BW edge image for ROI:
BW = edge(I_ROI,'canny');

%------------------------------------------------------------------------------------------
%% Calculate Hough transform:
[H,T,R] = hough(BW);

%------------------------------------------------------------------------------------------
%% Calculate peaks:
% Rotation:
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

x = T(P(:,2)); y = R(P(:,1));

Rotation = deg2rad(x + 90);

% Longest Line:
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
LinesNum = length(lines);
max_len = 0;
for k = 1:LinesNum
    xy = [lines(k).point1; lines(k).point2];
    
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len)
        max_len = len;
        LongestLine = xy;
    end
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    
    if (Flow.FrameIdx == 1)
        return
        
    elseif (Flow.FrameIdx == 2)
        h = figure('Name', 'Hough4ROI Debug','Units','normalized','Position',[0 0 1 1]);    
        
        if (Flow.VideoEn)
            vidObjDebugWR = VideoWriter(fullfile('..\Results\',strcat(Flow.VideoName,'Hough_Dbg')));
            vidObjDebugWR.FrameRate = Flow.fps;
            open(vidObjDebugWR);
            set(h, 'Resize', 'off');
        end
    else
        figure(h);
    end

    subplot(3,2,1);
    imshow(I,[]);
    hold on; 
    rectangle('Position',rect,'EdgeColor','r');
    title(sprintf('Brightness (Frame #%d)',Flow.FrameIdx));
    if (Flow.FrameIdx==2)
        zoom(2);
    end

    subplot(3,2,2);
    imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
    xlabel('\theta');
    ylabel('\rho');
    axis on;
    axis normal;
    hold on;
    plot(x,y,'s','color','white');
    plot(x(1),y(1),'s','color','g');
    title('Hough domain');

    subplot(3,2,3);
    imshow(BW);
    title('BW (edges)');

    subplot(3,2,[4 6]);
    imshow(I_ROI);
    hold on
    for k = 1:LinesNum
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end

    % Highlight the longest line segment
    plot(LongestLine(:,1),LongestLine(:,2),'LineWidth',2,'Color','blue');
    title('ROI with strong lines (BLUE=longest segment)');

    subplot(3,2,5);
    if (Flow.FrameIdx == 2)
        Rot = zeros(1,Flow.StopAtFrm);
        Rot(1) = x(1)+90;
    end
    Rot(Flow.FrameIdx:end) = repmat(x(1)+90,1,Flow.StopAtFrm-Flow.FrameIdx+1);
    plot(Rot,'r'); grid;
    xlabel('Frame (#)');
    ylabel('Rotation [deg]');
    title('Rotation per frame');

    if (Flow.VideoEn)
        F = getframe(h);
        writeVideo(vidObjDebugWR,F);    
   
        if (Flow.StopAtFrm == Flow.FrameIdx)
            close(vidObjDebugWR);
        end
    end    
end