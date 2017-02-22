function UpdatePlot(h, I, I_stable, Contour, CA, ME, Flow)

persistent ME_Arr

nFrames = Flow.StopAtFrm;
idx = Flow.FrameIdx;

if (idx == Flow.StartAtFrm)
    ME_Arr = zeros(4,nFrames); 
end

figure(h);

CenterCurr = CalcContourCentroid(CA.Contour);
CenterRef = CalcContourCentroid(CA.ContourRef);

BaseLineRef(:,1) = [ CenterRef(1)-20, CenterRef(1)+20 ];
BaseLineRef(:,2) = [ CenterRef(2),    CenterRef(2) ];

R   = ME.Rotation;
Cx  = CenterRef(1);
Cy  = CenterRef(2);
Off = CenterCurr - CenterRef;

BaseLineCurr(:,1) = round( cos(R)*(BaseLineRef(:,1)-Cx) - sin(R)*(BaseLineRef(:,2)-Cy) + Cx ) + Off(1);
BaseLineCurr(:,2) = round( sin(R)*(BaseLineRef(:,1)-Cx) + cos(R)*(BaseLineRef(:,2)-Cy) + Cy ) + Off(2);

%------------------------------------------------------------------------------------------
%% Original Image:
subplot(3,4,[5,6,9,10]);
imshow(I,[]);
title(['Original - Frame ',num2str(idx),'/',num2str(nFrames)]);
hold on;
plot(CA.Contour(1,:), CA.Contour(2,:),'-g');
plot(Contour(1,:)   , Contour(2,:)   ,'-r');
rectangle('Position',[CenterRef(1)-3, CenterRef(2)-3, 6,6],'Curvature',1, 'FaceColor','b');
rectangle('Position',[CenterCurr(1)-3,CenterCurr(2)-3,6,6],'Curvature',1, 'FaceColor','g');
plot(BaseLineRef(:,1),BaseLineRef(:,2),'LineWidth',2,'Color','blue');
plot(BaseLineCurr(:,1),BaseLineCurr(:,2),'LineWidth',2,'Color','green');
hold off;
hold off;
zoom(1.5);

%------------------------------------------------------------------------------------------
%% Stabilized Image:
subplot(3,4,[7,8,11,12]);
imshow(I_stable,[]);  
title(['Stabilized - Frame ',num2str(idx),'/',num2str(nFrames)]);
zoom(1.5);

%------------------------------------------------------------------------------------------
%% Motion Estimation:
ME_Arr(1,idx:end) = repmat(ME.dX,1,nFrames-idx+1);
ME_Arr(2,idx:end) = repmat(ME.dY,1,nFrames-idx+1);
ME_Arr(3,idx:end) = repmat(ME.Scale,1,nFrames-idx+1);
ME_Arr(4,idx:end) = repmat(ME.Rotation,1,nFrames-idx+1);

subplot(3,4,1); 
plot(ME_Arr(1,:)); 
ylim([0.95*min(ME_Arr(1,:)) max(1.05*max(ME_Arr(1,:)),eps)]);
title('Est. dX');

subplot(3,4,2); 
plot(ME_Arr(2,:)); 
ylim([0.95*min(ME_Arr(1,:)) max(1.05*max(ME_Arr(2,:)),eps)]);
title('Est. dY');

subplot(3,4,3); 
plot(ME_Arr(3,:)); 
ylim([0.95*min(ME_Arr(3,:)) max(1.05*max(ME_Arr(3,:)),eps)]);
title('Est. Scale');

subplot(3,4,4); 
plot(ME_Arr(4,:)); 
ylim([0.95*min(ME_Arr(4,:)) max(1.05*max(ME_Arr(4,:)),eps)]);
title('Est. Rotation');

drawnow;
