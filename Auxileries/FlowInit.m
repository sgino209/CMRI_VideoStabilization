function [h, vidObjWR1, vidObjWR2, dirname] = FlowInit(Flow)

%% Create results directory:
date = datestr(now);
datetok = strfind(date,' ');
datetime = date(datetok+1:end);
datetime = strrep(datetime,':','');
dirname = ['..\Results\Demo',num2str(Flow.DemoScheme),'_',strrep(datestr(now,2),'/',''),'_',datetime,'_k',num2str(Flow.SubMovie)];
mkdir(dirname);
copyfile('include.m',dirname);

%% Initiate main plotting:
if (Flow.PlotEn)
    h = figure('Name','Tracking','Units','normalized','Position',[0 0 1 1]);
end

%% Open video handler:
if (Flow.VideoEn)

    vidObjWR1 = VideoWriter(fullfile(dirname, Flow.VideoName));
    vidObjWR2 = VideoWriter(fullfile(dirname,'Stabilized'));
    
    vidObjWR1.FrameRate = Flow.fps;
    vidObjWR2.FrameRate = Flow.fps;
    
    open(vidObjWR1);
    open(vidObjWR2);

    % Resizing is forbidden from this point, as it will harm video capture:
    set(h, 'Resize', 'off');

else
    vidObjWR1 = [];
    vidObjWR2 = [];
end

%% Open diary logfile:
diary(fullfile(dirname, [Flow.VideoName,'Log.txt']));
