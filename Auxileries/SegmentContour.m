function [ContourSegments, varargout] = SegmentContour(Contour, Flow)

%% Calculate orientation for each point in the contour (Invarient to changes in R,S,dX,dY):

% 1. Find contour's centroid:
O = CalcContourCentroid(Contour);
N = length(Contour);

% 2. Calculate angle for each vertex (angle in triangle of 2 sequential vertices and the centroid):
ContourVects = Contour - repmat(O',1,N);
ContourVectsMag = sqrt(sum(ContourVects.^2));
ContourVectsNorm = ContourVects ./ repmat(ContourVectsMag, 2, 1);
ContourVectsAng = acos( sum( ContourVectsNorm(:,1:end-1) .* ContourVectsNorm(:,2:end) ) );

% 3. Derive accumulated angle for each vertex (last vertex=2*pi):
ContourVectsAngAcc = cumsum(ContourVectsAng);

% 4. Segment the contour for 8 segments (45 degrees each):
ContourSegments_pre1 = zeros(1,8);
ContourSegments_pre1(1) = 1;
for k=2:8
    ContourSegments_pre1(k) = find(ContourVectsAngAcc > 2*pi/8*(k-1), 1, 'first');
end

% 5. Remove sparse segments (contain less than 8% of total vertices):
N = length(Contour);
while (1)
    Q = length(ContourSegments_pre1);
    L = mod(diff([ContourSegments_pre1(end) ContourSegments_pre1]),N);
    Short = find(L<0.08*N, 1, 'first');

    if isempty(Short)
        break
    end
    
    a = mod( Short-2, Q ) + 1;
    b = mod( Short, Q ) + 1;
    ContourSegments_pre1(a) = ContourSegments_pre1(a) + floor(L(Short)/2);
    ContourSegments_pre1(b) = mod( ContourSegments_pre1(b) - ceil(L(Short)/2) - 1 , N) + 1;
    ContourSegments_pre1(Short) = [];
end

% 6. Generate final segmentation matrix:
ContourSegments_pre2 = reshape([ContourSegments_pre1 ; ContourSegments_pre1],1,2*length(ContourSegments_pre1));

ContourSegments_pre3 = [ContourSegments_pre2(2:end), ContourSegments_pre2(1)];

ContourSegments = reshape(ContourSegments_pre3,2,length(ContourSegments_pre3)/2)';

if (nargout == 2)    
    varargout(1) = { ContourOrientation };
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    figure('Name','Segmentation Debug');
    C = 1.5*max(Contour(1,:));
    R = 1.5*max(Contour(2,:));
    imshow(ones(R,C));
    hold on;
    SegmentsNum = length(ContourSegments);
    N = length(Contour);
    sectionColorPrev = [1 1 1];
    for k=1:SegmentsNum
        sectionColor = round(rand(1,3));
        while(all(sectionColor) || all(sectionColor == sectionColorPrev))
            sectionColor = round(rand(1,3));
        end
        from = ContourSegments(k,1);
        to   = ContourSegments(k,2);
        if (from > to)
            range = [from:N,1:to];
        else
            range = from:to;
        end
        plot(Contour(1,range), Contour(2,range), ...
            'color',sectionColor, 'linewidth', 3);
        sectionColorPrev = sectionColor;
    end
    hold off;
    title(sprintf('Orientations (%d)',SegmentsNum));
end