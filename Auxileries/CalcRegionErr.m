function err_reg = CalcRegionErr(target_samples, src_Reg_samples, Contour_src, R, S, dx, dy, Flow)

% For a direct comparison, Target and Source must be aligned with respect to the same origin:
    
ME.dX        = dx;
ME.dY        = dy;
ME.Rotation  = R;
ME.Scale     = S;
ME.ScaleEn   = 1;

%% Transform target region-patch to comparision location (aligned with Src):
ME.ScaleRef  = size(target_samples.ch1);
SR_fixed.ch1 = MotionCompansation(src_Reg_samples.ch1, Contour_src, ME, Flow);

%% Generate MSE/MSSIM error for region patches:
% Mask creation:
CC = RotateScaleOffsetContour(Contour_src, -R, 1/S, -dx, -dy);

ImMask = roipoly(target_samples.ch1, CC(1,:), CC(2,:));

% Unsharp (pre-process prior to similarity check):
H = fspecial('unsharp');

SR.ch1 = roifilt2(H, PreProcess(SR_fixed.ch1), ImMask);
TF1    = roifilt2(H, PreProcess(target_samples.ch1), ImMask);
TF2    = roifilt2(H, PreProcess(target_samples.ch2), ImMask);

% Errors calculation (use TF2 for weighting):
% Retrieve initial contour:
switch Flow.RegionMetric
    case 'MSE'
        err_reg = sum(sum( ( ImMask .* TF2 .* (TF1 - SR.ch1) ).^2 )) / sum(TF1(:));
    
    case 'SSIM'
        [mssim_ch1, ssim_map_ch1] = ssim(im2uint8(ImMask.*TF2.*TF1), im2uint8(ImMask.*TF2.*SR.ch1));    
        err_reg = 1 / mssim_ch1;
    
    case 'MI'
        MI = CalcMI(ImMask.*TF2.*TF1 ,ImMask.*TF2.*SR.ch1);
        err_reg = 1 / MI;
    
    otherwise
        warning('MATLAB:paramAmbiguous','Unexpected Region similarity measure: %s.',Flow.RegionMetric);
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (Flow.DebugPlotAdvEn)
    figure('Name','calcRegionErr debug');

    I1 = imfuse(SR_fixed.ch1, target_samples.ch1);
    h1=subplot(1,2,1);
    imshow(I1); 
    hold on; 
    plot(Contour_src(1,:), Contour_src(2,:), 'r');
    plot(CC(1,:), CC(2,:), 'g');
    hold off;
    title('CH1');
       
    h2=subplot(1,2,2);
    if strcmp(Flow.RegionMetric, 'SSIM')
        imshow(max(0, ssim_map_ch1).^4);
    else
        imshow(ImMask .* TF2 .* abs(TF1 - SR.ch1),[]); 
    end
    hold on; 
    plot(Contour_src(1,:), Contour_src(2,:), 'r');
    plot(CC(1,:), CC(2,:), 'g');
    hold off;
    title('CH1 error');
    
    linkaxes([h1 h2]);
end