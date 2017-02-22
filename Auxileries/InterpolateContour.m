function Contour = InterpolateContour(Initial, ContourPts)

N = length(Initial);

%% If Interpolation is needed:
if (N < ContourPts)
    % Calculate arcs lengths of Initial contour:
    InitialLens = sqrt( diff(Initial(1,:)).^2 + diff(Initial(2,:)).^2 );
    
    % Total contour length is equal to sum of all arcs length:
    ContourLen  = sum(InitialLens);
    
    % Split total quota of points (ContourPts) between all arcs:
    ArcsPts_pre = floor( (InitialLens / ContourLen) * ContourPts );
    
    % Split the spair quota "randomly" between all arcs, give zero lengths a priority:
    spairQuota = ContourPts - sum(ArcsPts_pre) - 1;
    emptyArcs = find(ArcsPts_pre == 0);
    if ~isempty(emptyArcs)
        emptyArcsNum = length(emptyArcs);        
        ArcsPts = ArcsPts_pre;        
        
        if (emptyArcsNum > spairQuota)
            LuckyArcs1 = randsample(emptyArcsNum,spairQuota);
            LuckyArcs2 = emptyArcs(LuckyArcs1);
            ArcsPts(LuckyArcs2) = ArcsPts_pre(LuckyArcs2) + ones(1,length(LuckyArcs2));
            spairQuota = 0;
        else
            ArcsPts(emptyArcs) = 1;
            spairQuota = spairQuota - length(emptyArcs);
        end
    else
        ArcsPts = ArcsPts_pre;
    end
    
    ArcsPtsFinal = ArcsPts;
    if (spairQuota)
        LuckyArcs = randsample(length(ArcsPtsFinal),spairQuota);
        ArcsPtsFinal(LuckyArcs) = ArcsPts(LuckyArcs) + ones(1,spairQuota);
    end

    
    % Interpolate (linearly) each arc:
    Contour = zeros(2,ContourPts);
    from = 1;
    for k=2:N
        ArcPts = ArcsPtsFinal(k-1);
        
        to = from + ArcPts;
        
        if (ArcPts == 1)
            Contour(:,from) = Initial(:,k-1);
        else
            Contour(1,from:to) = round( interp1(1:2, Initial(1,[k-1,k]), linspace(1,2,ArcPts+1)) );
            Contour(2,from:to) = round( interp1(1:2, Initial(2,[k-1,k]), linspace(1,2,ArcPts+1)) );
        end
        
        from = to;
    end
   
%% If Interpolation is not needed:    
else
    Contour = Initial;
end

%% Ensure a smooth circulation:
Contour(:,end) = Contour(:,1);