clear all; close all; diary off; clc;
dbstop if error
addpath('..\Auxileries');

%------------------------------------------------------------------------------------------------------------
%% Get contour from user:
h1=figure;
imshow(ones(500));
h2=msgbox('Please draw a closed contour (double-click to end)', 'PCA Demo');
uiwait(h2);
h3 = impoly;
tt = wait(h3);
Contour = [tt; tt(1,:)]';
close(h1);

%------------------------------------------------------------------------------------------------------------
%% Transform contour:
Rotate = -pi/2:pi/32:pi/2;
Scale  = 0.5:0.05:1.5;
Offset = -20:1:20;

R  = min(Rotate) + (max(Rotate) - min(Rotate)) .* rand(1,1);
S  = min(Scale)  + (max(Scale)  - min(Scale))  .* rand(1,1);
dx = min(Offset) + (max(Offset) - min(Offset)) .* rand(1,1);
dy = min(Offset) + (max(Offset) - min(Offset)) .* rand(1,1);

ContourAdj = RotateScaleOffsetContour(Contour, R, S, dx, dy);

%------------------------------------------------------------------------------------------------------------
%% Calculate rotation:
COEFF1 = princomp(ContourAdj');
COEFF2 = princomp(Contour');              
PCA_rot = asin(COEFF1(2)) - asin(COEFF2(2));

%------------------------------------------------------------------------------------------------------------
%% Plot:
center1 = CalcContourCentroid(Contour);
center2 = CalcContourCentroid(ContourAdj);

figure('Name', 'PCA Demo');
imshow(zeros(500));
hold on;
plot(Contour(1,:),Contour(2,:),'r');
plot(ContourAdj(1,:),ContourAdj(2,:),'g');
rectangle('Position',[center1(1)-5, center1(2)-5, 10,10],'Curvature',1, 'FaceColor','r');
rectangle('Position',[center2(1)-5, center2(2)-5, 10,10],'Curvature',1, 'FaceColor','g');
title(sprintf('R=%.3f, S=%.2f, dX=%.1f, dY=%.1f, PCA=%.3f', R, S, dx, dy, PCA_rot));
legend('User contour', 'Adjusted contour');
hold off;

fprintf('PCA error is: %.3f\n', abs(PCA_rot-R));