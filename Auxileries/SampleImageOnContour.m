function Samples = SampleImageOnContour(I, Contour, WinSize, WinSigma_pts, Flow)

N = size(Contour,2);
ContourX = int16(Contour(1,:));
ContourY = int16(Contour(2,:));

Samples = zeros(WinSize^2,N);

for k = 1:N
    halfWin = floor(WinSize/2);
    
    sample_range = [ContourY(k)-halfWin : ContourY(k)+halfWin ; ...
                    ContourX(k)-halfWin : ContourX(k)+halfWin ];
                    
    weightMask = fspecial('gaussian', WinSize, WinSigma_pts(k));
                       
    Sample = I(sample_range(1,:),sample_range(2,:)) .* weightMask;
    
    Samples(:,k) = Sample(:);
end

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)

    figure('Name','Contour Sampling Debug','Units','normalized','Position',[0 0 1 1]);
    
    subplot(1,2,1);
    surface(Samples);
    title('CH1: Brighness');
    view(162,50);
    
    subplot(1,2,2);
    imshow(I,[]);
    hold on; plot(ContourX,ContourY,'r-o'); hold off;
    zoom(2);

    colormap(jet);
end