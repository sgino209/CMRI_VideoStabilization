function targets = GenerateTargets(Channels, Contour, Flow)

targets = SampleImageInsideContour(Channels, Contour, Flow);


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    figure('Name','Target Generation Debug');
    
    h1=subplot(2,2,1);
    imshow(Channels.ch1,[]);
    hold on;
    plot(Contour(1,:),Contour(2,:),'r');
    hold off;
    title('CH1: Contour Sampling');
    
    h2=subplot(2,2,2);
    imshow(Channels.ch2,[]);
    hold on;
    plot(Contour(1,:),Contour(2,:),'r');
    hold off;
    title('CH2: Contour Sampling');
    
    h3=subplot(2,2,3);
    imshow(targets.ch1,[]);
    title('CH1: Region Sampling');
    
    h4=subplot(2,2,4);
    imshow(targets.ch2,[]);
    title('CH2: Region Sampling');
    
    linkaxes([h1 h2 h3 h4]);
    
    zoom(2)
end