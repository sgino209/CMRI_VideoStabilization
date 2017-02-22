function Contour = GetInitialContour(Flow, Params, h, J)

% Retrieve initial contour:
if Flow.DemoScheme
    Initial = Flow.DemoContour;
else
    figure(h);
    imshow(J);
    hh=msgbox('Please select ROI (initial contour)', 'ROI Selection');
    uiwait(hh);
    hh = impoly();
    Initial = wait(hh);
    Initial = [Initial; Initial(1,:)]';
end

% Interpolate (if needed):
Contour = InterpolateContour(Initial, Params.ContourPts);


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    figure;
    imshow(J);
    hold on;
    plot(Initial(1,:), Initial(2,:),'rs', 'Linewidth', 3);
    plot(Contour(1,:), Contour(2,:),'go');
    hold off;
end