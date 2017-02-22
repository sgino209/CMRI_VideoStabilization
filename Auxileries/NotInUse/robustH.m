% calcH - computes homography
%
% Usage:   H = robustH(p1, p2, f, s)
%
% Arguments:
%          p1  - 2xN set of homogeneous points
%          p2  - 2xN set of homogeneous points such that p1<->p2
%           f - relative amount of inliers points (=#inliers/length(p1)
%           s - required precision (LS).
% Returns:
%          H - the 3x3 homography such that p2 = H*p1
%          bestinliers - inliers that accepts the model (optional).
% This code is modelled by RANSAC algorithm given in lecture.
%

% Shahar Gino
% School of Electrical Engineering
% Tel-Aviv University
% shaharg8@mail.tau.ac.il
%
% December 2010

function varargout = robustH(p1, p2,f,s)

    %% Add third coordinate:
    Npts = length(p1);
    p1 = [p1 ; ones(1,Npts)];
    p2 = [p2 ; ones(1,Npts)];  

	%% Definitions:
    n = 8;                        % Minimum number of samples that defines a model.
    p = 0.99;                   % Desired probability of success (affects trials number).

    %% Initialization (best model & trials number):
    bestscore =  0;
    bestM = NaN;
    bestinliers = NaN;
	K = round(log(1-p)/log(1 -  f^n));

    %% RANSAC core:
	for trialcount = 1:K
        % 1. Select at random n datapoints to form a trial model, M:
    	ind = randsample(Npts, n);   

        % 2. Estimate model to this random selection of data points:
        M = calcH(p1(1:2,ind),p2(1:2,ind));

        % 3. Find inliers that accept the model (i.e. p2=M*p1 with minimum LS error):
        p2_est = M*p1;  p2_est = p2_est./[p2_est(3,:); p2_est(3,:); p2_est(3,:)];
        p1_est = M\p2;  p1_est = p1_est./[p1_est(3,:); p1_est(3,:); p1_est(3,:)];
        err = sum((p1-p1_est).^2)  + sum((p2-p2_est).^2);
        inliers = find(sqrt(err) < s); 
        Ninliers = length(inliers);
        
        % 4. Record data if inliers set is larger than before, else recompute:
        if Ninliers > bestscore
            bestscore = Ninliers;
            bestM = M;
            bestinliers = inliers;        
        end
	end
   
    %% Return best model:
    if ~isnan(bestM)   % We got a solution 
        varargout{1} = bestM;
        if (nargout==2)
            varargout{2} = bestinliers;
        end
        display(['[robustH]  Done after ', num2str(K) ,' interations (found ', num2str(bestscore), ' inliers)']);
    else           
        error('[robustH]  Unable to find a useful solution');
    end

end
