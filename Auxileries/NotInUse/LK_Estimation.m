function [ContourAdj,P] = LK_Estimation(Channels_curr, Channels_prev, Contour)

ITERS = 9;

I1 = Channels_curr.ch1;
I2 = Channels_prev.ch1;

X  = Contour(1,:);
Y  = Contour(2,:);

N  = length(Contour);

Ix = conv2(I2,[-0.5 , 1 , -0.5],'same');
Iy = conv2(I2,[-0.5 ; 1 ; -0.5],'same');

P = [1 0 0 ; 0 1 0];

P_arr = zeros(ITERS,6);

figure; 

for iter=1:ITERS
    
    P_arr(iter,:) = reshape(P',6,1);
    
    It = zeros(N,1);
    B = zeros(N,6);
    for k=1:N
        B(k,:) = [ Ix(Y(k),X(k))*X(k) , Ix(Y(k),X(k))*Y(k) , Ix(Y(k),X(k)) , ...
                   Iy(Y(k),X(k))*X(k) , Iy(Y(k),X(k))*Y(k) , Iy(Y(k),X(k)) ];
        
        ContourWrap = max(0, min( round( P * [Contour ; ones(1,N)] ) , repmat(fliplr(size(I2))',1,N) ));
        
        It(k) = I2(ContourWrap(2,k),ContourWrap(1,k)) - I1(Contour(2,k),Contour(1,k));
    end
    
    dP = -inv(B'*B)*B'*It;
    
    P = P + reshape(dP,3,2)';

    ContourAdj = P * [Contour ; ones(1,N)];
    
    subplot(3,3,iter); imshow(I1); hold on; plot(ContourAdj(1,:),ContourAdj(2,:),'-ro'); hold off; title(sprintf('Iter %d',iter));
    
end