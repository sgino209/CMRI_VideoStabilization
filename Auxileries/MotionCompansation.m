function I_stable = MotionCompansation(I, Contour, ME, Flow)

if ((Flow.FrameIdx == Flow.StartAtFrm) || ~mod(Flow.FrameIdx,Flow.Manual_CA))
    I_stable = I;
    return
end


%% Common parameters:
I_stable_pre1 = I;

center_curr  = CalcContourCentroid(Contour);

dx  = ME.dX;
dy  = ME.dY;
Rot = ME.Rotation;
Scl = ME.Scale;


%% Horizontal Offset fix:
if (dx>0)
    I_stable_pre1 = [ I_stable_pre1(:,dx+1:end,:) , ...
                      zeros(size(I_stable_pre1,1),dx,size(I_stable_pre1,3)) ];
elseif (dx<0)
    dx = abs(dx);
    I_stable_pre1 = [ zeros(size(I_stable_pre1,1),dx,size(I_stable_pre1,3)) , ...
                      I_stable_pre1(:,1:end-dx,:) ];
end


%% Vertical Offset fix:
if (dy>0)
    I_stable_pre1 = [ I_stable_pre1(dy+1:end,:,:)                          ; ...
                      zeros(dy,size(I_stable_pre1,2),size(I_stable_pre1,3)) ];
elseif (dy<0)
    dy = abs(dy);
    I_stable_pre1 = [ zeros(dy,size(I_stable_pre1,2),size(I_stable_pre1,3)) ; ...
                      I_stable_pre1(1:end-dy,:,:)                          ];
end


%% Rotation fix:
[X,Y] = meshgrid(1:size(I,2), 1:size(I,1));

center_shift = [center_curr(1) - ME.dX , center_curr(2) - ME.dY];

X_shift = X - center_shift(1);
Y_shift = Y - center_shift(2);

Xi = center_shift(1) + cos(Rot)*X_shift - sin(Rot)*Y_shift;
Yi = center_shift(2) + sin(Rot)*X_shift + cos(Rot)*Y_shift;

if (size(I_stable_pre1,3)==3)
    I_stable_pre2(:,:,1) = interp2(X, Y, I_stable_pre1(:,:,1), Xi, Yi, 'linear');
    I_stable_pre2(:,:,2) = interp2(X, Y, I_stable_pre1(:,:,2), Xi, Yi, 'linear');
    I_stable_pre2(:,:,3) = interp2(X, Y, I_stable_pre1(:,:,3), Xi, Yi, 'linear');
else
    I_stable_pre2 = interp2(X, Y, I_stable_pre1, Xi, Yi, 'linear');
end

I_stable_pre2(isnan(I_stable_pre2))=0;


%% Scale Fix (if enabled):
if (ME.ScaleEn && Scl~=1)
    I_stable_pre3 = imresize(I_stable_pre2, 1/Scl);
    
    R1 = ME.ScaleRef(1) - size(I_stable_pre3,1);
    C1 = ME.ScaleRef(2) - size(I_stable_pre3,2);
    
    % Case 1:  Scl is approx. 1 --> no change in scale:
    if (R1==0 || C1==0)
        I_stable = I_stable_pre2;
    
    % Case 2:  Scl<1 --> TGT is smaller than SRC, therefore need to be padded:
    elseif (R1>0 && C1>0)
        I_stable = padarray(I_stable_pre3,[floor(R1/2),floor(C1/2)]);
        if mod(R1,2)
           I_stable = [I_stable ;  zeros(1,size(I_stable,2))];
        end
        if mod(C1,2)
           I_stable = [I_stable ,  zeros(size(I_stable,1),1)];
        end

    % Case 3:  Scl>1 --> TGT is larger than SRC, therefore need to be cropped:
    elseif (R1<0 && C1<0)
        xmin = -C1/2;
        ymin = -R1/2;
        w    = size(I_stable_pre3,2) + C1 - 1;
        h    = size(I_stable_pre3,1) + R1 - 1;
        I_stable = imcrop(I_stable_pre3,[xmin,ymin,w,h]);
    end

else
    I_stable = I_stable_pre2;
end
