function I_SORF = CalculateSORF(I)

si = size(I);
N = ceil(log2(min(si(1:2)))) - 4;
gap = 1;

%% Generate a Blurred pyramid:
BlurredPyramid = cell(1,N+gap);

BlurredPyramid{1} = I;
for k=2:N+gap
    BlurredPyramid{k} = my_impyramid(BlurredPyramid{k-1} , 'reduce')+1e-9;
end

%% Generate a CenterSrnd pyramid:
SorfPyramid = cell(1,N);
CenterSrndPyramid = cell(1,N);

for i=1:N
    Ip = BlurredPyramid{i};
    Iexpand = BlurredPyramid{i+gap};
    for g= 1:gap
        Iexpand= (my_impyramid(Iexpand, 'expand'));
    end
    CenterSrnd = abs(Ip - Iexpand).^0.4;
    CenterSrndPyramid{i} = CenterSrnd;
end

%% Generate SORF Pyramid
SorfPyramid{N} = CenterSrndPyramid{N};
for i=N-1:-1:1
      SorfPyramid{i} = CenterSrndPyramid{i} + (my_impyramid(SorfPyramid{i+1}, 'expand'));
end

I_SORF = CenterSrndPyramid{1};%SorfPyramid{1};
I_SORF = I_SORF(1:si(1),1:si(2));


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% D E B U G:
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (0)
    figure('Name', 'SORF'); 
    h1=subplot(2,2,1); imshow(SorfPyramid{1},[]);
    h2=subplot(2,2,2); imshow(SorfPyramid{2},[]);
    h3=subplot(2,2,3); imshow(SorfPyramid{3},[]);
    h4=subplot(2,2,4); imshow(SorfPyramid{4},[]);
    linkaxes([h1 h2 h3 h4]);
    
    figure('Name', 'CenterSrndPyramid'); 
    h1=subplot(2,2,1); imshow(CenterSrndPyramid{1},[]);
    h2=subplot(2,2,2); imshow(CenterSrndPyramid{2},[]);
    h3=subplot(2,2,3); imshow(CenterSrndPyramid{3},[]);
    h4=subplot(2,2,4); imshow(CenterSrndPyramid{4},[]);
    linkaxes([h1 h2 h3 h4]);
end