function ContourAdj = NonLinearContourAdjust(Contour, I_pre, Params, Flow)

Score_Weights_pts = ones(1,length(Contour)); %TBD

%% Snake support (aimed for "easy" tracking schemes):
if (Flow.FE_useSnake)
    ImMask = roipoly(I_pre, Contour(1,:), Contour(2,:));
    I = Snake(I_pre, ImMask, 5, .1, false);
else
    I = I_pre;
end

%------------------------------------------------------------------------------------------
%% Contour resolution:
N = size(Contour,2);

%------------------------------------------------------------------------------------------
%% Generate shrinked and expanded contours:
Shrink = Params.FE_Shrink;
Expand = Params.FE_Expand;

ContourAdj_shrink = RotateScaleOffsetContour(Contour, 0, Shrink, 0, 0);
ContourAdj_expand = RotateScaleOffsetContour(Contour, 0, Expand, 0, 0);

%------------------------------------------------------------------------------------------
%% Seek for contrast gradients between the 2 contours:
M = 200;
t = linspace(0,1,M);
Cost = N/10;
CostVec = zeros(1,N); %debug
ContourAdj_pre = Contour;
for k=1:N
    %% Generate shrinked and extended contours:
    p1 = ContourAdj_shrink(:,k);
    p2 = ContourAdj_expand(:,k);
    
    %% Connect the 2 contours:
    p1p2_vec = floor( repmat(p1,1,M) + repmat(t,2,1) .* repmat(p2-p1,1,M) );
    unique_mask = repmat([1,any(diff(p1p2_vec,1,2))],2,1);
    p1p2_vec_uniq_pre = nonzeros( unique_mask .* p1p2_vec );
    p1p2_vec_uniq = reshape(p1p2_vec_uniq_pre,2,length(p1p2_vec_uniq_pre)/2);
    L = length(p1p2_vec_uniq); x=1:L;
    
    %% Sample contrast path between the 2 contours (inner to outer):
    p1p2_sample = I(sub2ind(size(I),p1p2_vec_uniq(2,:),p1p2_vec_uniq(1,:)));
    
    %% Calculate the new index:
    % 1. Find local minimas in brightness (give advantage to middle positions):
    alpha = 14;

    G = (N/alpha)*sqrt(Score_Weights_pts(k));                       % It seems that alpha=3 works
    p1p2_gaussian_pre = exp(-G.^2*(((x-L/2))./(L/2)).^2)';          % well for CMRI while alpha=14
    p1p2_gaussian = (1+min(p1p2_gaussian_pre)-p1p2_gaussian_pre);   % works well for synthetic (TBD...)
    
    if (Flow.FE_useSnake)
        p1p2_sample_final = p1p2_sample; 
    else
        p1p2_sample_filt = smooth(p1p2_sample)';       
        p1p2_sample_final = p1p2_sample_filt' .* p1p2_gaussian;
    end
    [~,p1p2_sample_gmin] = min(p1p2_sample_final);

    % 2. Find gradient peaks:
    p1p2_sample_filt_grad      = abs(gradient(p1p2_sample_filt));
    p1p2_sample_grad_lmax_pre  = local_max(p1p2_sample_filt_grad);
    if isempty(p1p2_sample_grad_lmax_pre)
        p1p2_sample_grad_newInd = L/2;
    else
        p1p2_sample_grad_lmax_pre(p1p2_sample_grad_lmax_pre==1) = [];
        p1p2_sample_grad_lmax_pre(p1p2_sample_grad_lmax_pre==length(p1p2_sample_filt_grad)) = [];
        
        if isempty(p1p2_sample_grad_lmax_pre)
            p1p2_sample_grad_newInd = L/2;
        else
            [p1p2_sample_grad_lmax_srt,IX] = sort(p1p2_sample_filt_grad(p1p2_sample_grad_lmax_pre));
            p1p2_sample_grad_lmax      = p1p2_sample_grad_lmax_pre(IX);
            p1p2_sample_grad_lmax_ind1 = p1p2_sample_grad_lmax(end);
            p1p2_sample_grad_lmax_val1 = p1p2_sample_grad_lmax_srt(end);
            if length(p1p2_sample_grad_lmax_pre)==1
                p1p2_sample_grad_newInd = p1p2_sample_grad_lmax_ind1;
            else
                p1p2_sample_grad_lmax_ind2 = p1p2_sample_grad_lmax(end-1);
                p1p2_sample_grad_lmax_val2 = p1p2_sample_grad_lmax_srt(end-1);
                W1 = p1p2_sample_grad_lmax_val1.*p1p2_gaussian_pre(p1p2_sample_grad_lmax_ind1);
                W2 = p1p2_sample_grad_lmax_val2.*p1p2_gaussian_pre(p1p2_sample_grad_lmax_ind2);
                p1p2_sample_grad_newInd = NormSoft([W1 W2]) * ...
                                                   [p1p2_sample_grad_lmax_ind1 ; p1p2_sample_grad_lmax_ind2];
            end
        end
    end
    
    % 3. Support from neighbours (spacial prediction):
    if (k==1)
        pred_prev = [];
    else
        pred_prev = (ContourAdj_newInd_prev / L_prev) * L;
    end
    
    % 4. Blend:
    ContourAdj_newInd = round( mean([p1p2_sample_gmin, ...
                                     p1p2_sample_grad_newInd, ...
                                     pred_prev]) );

    % 5. Update total cost:   
    if strcmp(Params.FE_CostMode,'ShrinkOnly')
        Offset = (ContourAdj_newInd - round(L/2));  % pay for expanding (new > cur)
    
    elseif strcmp(Params.FE_CostMode,'ExpandOnly')
        Offset = (round(L/2) - ContourAdj_newInd);  % pay for shrinking (new < cur)
    end
    
    if ~strcmp(Params.FE_CostMode,'NoCostLimit')        
        Cost = Cost - Offset;                       % cost balance (either positive or negative).
        
        if (Cost <= 0)
            ContourAdj_newInd = round(L/2);         % revert update attempt in case of overdraft
        end
    end    
    CostVec(k) = Cost;
    
    %% New index update:
    ContourAdj_newInd_prev = round(L/2);

    if (~isempty(ContourAdj_newInd))
        ContourAdj_pre(:,k) = p1p2_vec_uniq(:,ContourAdj_newInd);
        
        ContourAdj_newInd_prev = ContourAdj_newInd;
    end
    
    L_prev = L;
end

%------------------------------------------------------------------------------------------
%% Undo outliers (due to textures, noise, etc) by LPF smoothing ("moving avergae", span=3):
TotalDist = sum(sqrt(sum((ContourAdj_pre - Contour).^2)));
if (TotalDist > 0.75*N)
    ContourAdj_round(1,:) = round( smooth(ContourAdj_pre(1,:),3) );
    ContourAdj_round(2,:) = round( smooth(ContourAdj_pre(2,:),3) );
else
    ContourAdj_round = ContourAdj_pre;
end

%------------------------------------------------------------------------------------------
%% Uniqify and Interpolate (if needed):
unique_mask1 = [~((diff(ContourAdj_round(1,:),1,2)==0) .* (diff(ContourAdj_round(2,:),1,2)==0)),1];
unique_mask2 = repmat(unique_mask1, 2, 1);
ContourAdj_uniq_pre = nonzeros(unique_mask2 .* ContourAdj_round);
ContourAdj_uniq     = reshape(ContourAdj_uniq_pre,2,length(ContourAdj_uniq_pre)/2);

ContourAdj = InterpolateContour(ContourAdj_uniq, Params.ContourPts);


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)   
    figure('Name','NonLinearContourAdj debug');
    
    subplot(2,2,[1 3]);
    plot(p1p2_sample,'r');
    hold on;
    plot(p1p2_sample_filt,'g');
    plot(p1p2_sample_final,'b');
    plot(gradient(p1p2_sample_filt),'--r');
    plot(p1p2_sample_filt_grad,'m');
    plot(p1p2_gaussian,'--c');
    hold off;
    if isempty(ContourAdj_newInd)
        title(sprintf('k=%d, G=%.2f, BRmin=%d, NewInd=%d', ...
            k, G, p1p2_sample_gmin, round(L/2)));
    else
        title(sprintf('k=%d, G=%.2f, BRmin=%d, GradPeaksMid=%.2f, PrevPred=%.2f, NewInd=%d', ...
            k, G, p1p2_sample_gmin, p1p2_sample_grad_newInd, pred_prev, ContourAdj_newInd));
    end
    legend('P1P2 samples','After LPF','Final (postProb)','Grad','ABS(Grad)','Gaussian prob.','Location','Best');
    
    subplot(2,2,2);
    bar(Score_Weights_pts/max(Score_Weights_pts(:)), 0.7, 'b');
    hold on;
    plot(CostVec/max(CostVec(:)), 'r', 'LineWidth', 2);
    hold off;
    title('Normalized Points-Weights and Costs (after update)');
    xlim([0,N+1]);
    legend('Weights','Costs','Location','Best');
    
    subplot(2,2,4);
    imshow(I,[]);
    hold on;
    plot(p1p2_vec_uniq(1,:),p1p2_vec_uniq(2,:),'-c');
    plot(Contour(1,:), Contour(2,:),'-go');
    plot(ContourAdj_shrink(1,:), ContourAdj_shrink(2,:),'-rs');
    plot(ContourAdj_expand(1,:), ContourAdj_expand(2,:),'-rs');
    plot(ContourAdj_pre(1,:), ContourAdj_pre(2,:),'-yd');
    plot(ContourAdj(1,:), ContourAdj(2,:),'-m*');
    hold off;
    legend('P1P2','Original', 'Shrinked', 'Expanded', 'PreLPF', 'Final','Location','Best');
    title('Shrink-And-Expand view');
end