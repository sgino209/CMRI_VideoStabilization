% calcH - computes homography
%
% Usage:   H = calcH(p1, p2)
%
% Arguments:
%          p1  - 2xN set of homogeneous points
%          p2  - 2xN set of homogeneous points such that p1<->p2
% Returns:
%          H - the 3x3 homography such that p2 = H*p1
%
% This code is modelled by "8-points" algorithm given in lecture.
%

% Shahar Gino
% School of Electrical Engineering
% Tel-Aviv University
% shaharg8@mail.tau.ac.il
%
% December 2010

function H = calcH(p1, p2)

	%% Check matrix sizes
	if ~all(size(p1) == size(p2))
        error('p1 and p2 must have same dimensions');
	end

    %%  Add third coordinate (homogenous):
    Npts = length(p1);
    p1 = [p1 ; ones(1,Npts)];
    p2 = [p2 ; ones(1,Npts)];  

	%% Normalise each set of points:
    % The origin is at centroid and mean distance from origin is sqrt(2)
    [p1, T1] = normalise2dpts(p1);
    [p2, T2] = normalise2dpts(p2);
  
    %% Calculation:
    A = zeros(2*Npts,9);
	O = [0 0 0];
    for n = 1:Npts
        X = p1(:,n)';
    	x = p2(1,n); y = p2(2,n); w = p2(3,n);
    	A(2*n-1,:) = [  O  -w*X  y*X];
    	A(2*n,:)    = [ w*X   O  -x*X];
    end

    %% Solve the Homography using SVD:
    [U,S,V] = svd(A,0);               % A = U*S*V'
	H = reshape(V(:,9),3,3)';	% H = column of V corresponding to smallest singular value.
    H = T2\H*T1;                         % Denormalise

end

%% Auxelary function for normalizing 2D points:
function [newpts, T] = normalise2dpts(pts)
  
    c = mean(pts(1:2,:),2);                                                   % Centroid of finite points
    newp(1:2,:) = pts(1:2,:)-c*ones(1,length(pts)); % Shift origin to centroid.
	R = sqrt(newp(1,:).^2 + newp(2,:).^2);                        % Distance from centroid
    scale = sqrt(2)/mean(R(:));                                        % Mean distance from origin should be sqrt(2)
    
    % Normalization matrix:
    T = [scale   0   -scale*c(1)
         0     scale -scale*c(2)
         0       0      1      ];
    
    newpts = T*pts;     % newX = sqrt(2) * (x-<x>/<R>)
                                            % newY = sqrt(2) * (y-<y>/<R>)
end