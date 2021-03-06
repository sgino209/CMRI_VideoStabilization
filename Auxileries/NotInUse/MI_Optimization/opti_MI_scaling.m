% 2D Mutual Information Matching using Optimization toolbox
% 
% In image.mat, IM1 and IM2 are included.
% 
% IM1: 230 X 230 MRI image
% IM2: 512 X 512 CT image
% 
% Your selection of initial point x0 is critical for this matching.
% 
% x0(1): First index of row for cropping the rotated IM2 with x0(3) angle
% x0(2): First index of column for cropping the rotated IM2 with x0(3) angle
% x0(3): Angle
% x0(4): Scale factor
% 
% The 'fminsearch' function in the Optimization Toolbox is used.  
% The objection function is 'image_registr_MI.m'
%
% Date: Feb. 22, 2005
% Author: Hosang Jin
% Graduate Student
% University of Florida
% Email: hsjin@ufl.edu

close all
clear all

tic

x0=[50; 50; -15; 0.5]; % Initial points, [X, Y, angle, scaling] 
                       % Select them as close to the matching points as possible
                       % by guessing; otherwize, it will fail.

[x, fval]=fminsearch(@image_registr_MI,x0); % Optimization using 'fminsearch'

fprintf('dX=%.2f, dY=%.2f, Rotation=%.2f, Scale=%.2f\n',x);
toc

%------------------------------------------------------------------------------------
%% Display
%------------------------------------------------------------------------------------
load image

IM1=double(IM1);
IM2=double(IM2);

IM3=imresize(IM2, x(4), 'bilinear');
J=imrotate(double(IM3), x(3),'bilinear'); %rotated cropped IMAGE2

[n1, n2]=size(IM1);
[n3, n4]=size(J);
position=1:n1;
xx=round(position+x(1));
yy=round(position+x(2));

IM3=round(J(xx, yy));

figure('Name','MI Registration','Units','normalized','Position',[0 0 1 1]);
subplot(1,3,1), imshow(IM1, []), title('Image 1 - MRI input')
subplot(1,3,2), imshow(IM2, []), title('Image 2 - CT input')
subplot(1,3,3), imshow(IM3, []), title('Image 2 - CT, Registered (MI)')