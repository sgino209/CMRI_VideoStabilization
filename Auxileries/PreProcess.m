function [I,J] = PreProcess(J_pre)

%------------------------------------------------------------------------------------------
%% Normalization [0,1]:
J = im2double(J_pre);
J = J - min(J(:));
J = J ./ max(J(:));

%------------------------------------------------------------------------------------------
%% RGB --> gray:
if (size(J,3) == 3)
    I = rgb2gray(J);
else
    I = J;
end

%------------------------------------------------------------------------------------------
%% Smooth (reduce noise, preserve edges):
I = medfilt2(I,[3 3]);