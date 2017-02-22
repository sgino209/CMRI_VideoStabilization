function score = ContourDistByArea(C1, C2, DebugEn)

%% Get pseudo-image size:
SizeX = max(max(C1(1,:)), max(C2(1,:))) + 10;
SizeY = max(max(C1(2,:)), max(C2(2,:))) + 10;

%% Interpolate in order to increase precision:
N = max(length(C1),length(C2));
IntFactor = 40;
M = IntFactor*N;
C1_Int = InterpolateContour(C1, M);
C2_Int = InterpolateContour(C2, M);

%% Generate filled BW images from the input contours:
BW1 = im2bw(zeros(SizeY,SizeX));
BW2 = im2bw(zeros(SizeY,SizeX));
BW1(sub2ind(size(BW1),C1_Int(2,:),C1_Int(1,:))) = 1;
BW2(sub2ind(size(BW2),C2_Int(2,:),C2_Int(1,:))) = 1;
J1 = imfill(BW1, 'holes');
J2 = imfill(BW2, 'holes');

%% Calculate area:
PS = (J1+J2 == 2); % Positive
FN = max(0,J1-J2); % False Negative
TN = max(0,J2-J1); % True Negative

%% Calculate similarity ("score"):
score = sum(sum( PS - (FN + TN) ));


%-------------------------------------------------------------------------------------------
%% Debug:
if (DebugEn)
    figure('Name', 'Rotation debug','Units','normalized','Position',[0 0 1 1]);
    
    h(1)=subplot(2,2,1);
    imshow(zeros(SizeY,SizeX));
    hold on;
    plot(C1(1,:),C1(2,:),'-r');
    plot(C2(1,:),C2(2,:),'-g');
    hold off;
    title('C1 vs C2');
       
    h(2)=subplot(2,2,2); imshow(P);  title('Positive');
    h(3)=subplot(2,2,3); imshow(FN); title('False Negative');
    h(4)=subplot(2,2,4); imshow(TN); title('True Negative');
    
    linkaxes(h);
end