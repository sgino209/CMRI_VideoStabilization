function MI = CalcMI(I1,I2)

IM1=im2uint8(I1);
IM2=im2uint8(I2);
    
rows = size(IM1,1);
cols = size(IM2,2);
N = 256;

%% Normalized joint histogram:
h = zeros(N,N);

for ii=1:rows;    %  col
    for jj=1:cols;   %   rows
        h(IM1(ii,jj)+1,IM2(ii,jj)+1)= h(IM1(ii,jj)+1,IM2(ii,jj)+1)+1;
    end
end

[r,c] = size(h);

b = h ./ (r*c); % normalized joint histogram

y_marg = sum(b,1); %sum of the rows of normalized joint histogram
x_marg = sum(b,2); %sum of columns of normalized joint histogran

%% Marginal entropy for image 1
Hy=0;
for i=1:c;
    if( y_marg(i)~=0 )
        Hy = Hy + -(y_marg(i)*(log2(y_marg(i))));
    end
end

%% Marginal entropy for image 2
Hx=0;
for i=1:r;
    if( x_marg(i)~=0 )
        Hx = Hx + -(x_marg(i)*(log2(x_marg(i))));
    end
end

%% Joint entropy:
h_xy = -sum(sum(b.*(log2(b+(b==0)))));

%% Mutual information:
MI = -(Hx + Hy - h_xy);