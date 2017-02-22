function out = LIcontourOrintationAndLIines(I)

resnumb=1;
ORIres=16;
nORI=9;
nSCL=20;
nn=2;
C50=0.3;
aCs=1;%0.4;
qq=5;


ORIres=2*abs(ORIres./2);

I = double(I(:,:,1));
I=I/max(I(:));
%  figure; imagesc(I); colormap gray

Contrast=zeros(size(I,1),size(I,2),1.5*ORIres);
LIContrastORI=zeros(size(I,1),size(I,2),1.5*ORIres);

LIContrast=zeros(size(I,1),size(I,2),1.5*ORIres);

out=zeros(size(I,1),size(I,2),1);
LIout=zeros(size(I,1),size(I,2),1);

outS=zeros(size(I,1),size(I,2),1);
LIoutS=zeros(size(I,1),size(I,2),1);

for i = 1 : resnumb
    
    size1 = 2.*(i-1)*(i>1)+1;
    
    H = zeros(size1*3);
    
    mid = ceil(size(H,1)/2);
    
    H((size1):(3*size1),1:size1) = -0.5;
    H((size1):(3*size1),(size1+1):2*size1) = 0.5;
   
    H((size1+1):2*size1,1:size1) = -1;
    H((size1+1):2*size1,(size1+1):2*size1) = 1;
    
    
    ContrastORI = zeros(size(I,1),size(I,2),1.5*ORIres);
%     LIContrastORI=ContrastORI;
    maxmax=0;
    
    normC = zeros(size(I,1),size(I,2));
    Snorm = zeros(size(I,1),size(I,2));
    
    for j = 1 : (1.5*ORIres)
        
        if j<=ORIres
            tat = (j-1)*360/ORIres;

            kern = imrotate(H,tat,'bilinear','crop');

            sumNeg = 2*sum(sum((kern<0).*kern));
            sumPos = 2*sum(sum((kern>0).*kern));
            kern = (kern>0).*kern./(1e-2+sumPos) +(kern<0).*kern./abs(-1e-2+sumNeg);
            kern2 = abs(kern);
        else
            tat = (j-1)*360/ORIres-360;
            H2=0.5*(H+imrotate(H,180));

            kern = imrotate(H2,tat,'bilinear','crop');

            sumNeg = sum(sum((kern<0).*kern));
            sumPos = sum(sum((kern>0).*kern));
            kern = (kern>0).*kern./(1e-2+sumPos) +(kern<0).*kern./abs(-1e-2+sumNeg);
            kern2 = abs(kern);
            
        end
        
        ContrastORI(:,:,j) = min(1,max(0,conv2(I,kern,'same'))./max(1e-2,conv2(I,kern,'same')).^0.5);
        
         fLOG = max(0,0.01+fspecial('log', 14*size1+1, 1.5));
         fLOG = fLOG./sum(sum(fLOG));
        
        Snorm = max(Snorm,conv2(ContrastORI(:,:,j).^0.5,fLOG,'same')); %% 3

        
%         C50a= C50+aCs*Cs;

%         ContrastORI(:,:,j) = ContrastORI(:,:,j).^nn./(ContrastORI(:,:,j).^nn+C50a.^nn);
       




%          normC = normC+ContrastORI(:,:,j).^qq;
        normC = max(normC,ContrastORI(:,:,j));

        
%         h = fspecial('motion',20 , tat+90);
% 
% 
%         LI = imfilter(ContrastORI(:,:,j),h,'replicate')*10;
        
         maxmax=max(maxmax,max(max(ContrastORI(:,:,j))));
%          LIContrastORI(:,:,j) = min(maxmax,max(ContrastORI(:,:,j)+0.25*LI,ContrastORI(:,:,j)));
%         
% 
% %          
%      localmax1=0.15*imregionalmax(ContrastORI(:,:,j),min(8,4*round(3*size1/4))).*ContrastORI(:,:,j);
%      SE = strel('disk',16*size1); %%9
%      localmax1=imdilate(localmax1,SE);
%      localmax1=imclose(localmax1,SE);
% %      localmax=max(localmax,0.05*max(max(ContrastORI(:,:,j))));
%      LIContrast(:,:,i)=(LIContrastORI(:,:,j)>localmax1).*LIContrastORI(:,:,j);
% %      LIContrast(:,:,i)=max(LIContrastORI(:,:,j),ContrastORI(:,:,j));
% 
% 
%                      
% %         Contrast(:,:,i) = Contrast(:,:,i) + ContrastORI(:,:,j).^nORI;
%          Contrast(:,:,i) = max(Contrast(:,:,i),ContrastORI(:,:,j));
%          LIContrast(:,:,i) = max(LIContrast(:,:,i),LIContrastORI(:,:,j));
            
    end
    
         se1 = strel('disk',15);
        Snorm = imdilate(Snorm,se1);
    
    for j = 1 : ORIres
        ContrastORI(:,:,j) = (ContrastORI(:,:,j).^3./normC.^2); %% 
%         figure; imagesc(ContrastORI(:,:,j));
%         title(num2str((j-1)*360/ORIres));
    end
    
  
    for j = 1 : ORIres
       tat = (j-1)*360/ORIres;
       
%           C50a= C50+aCs*Snorm
          C50a= (C50+aCs*Snorm);

           ContrastORI(:,:,j) = ContrastORI(:,:,j).^nn./(ContrastORI(:,:,j).^nn+C50a.^nn);
%           ContrastORI(:,:,j) = ContrastORI(:,:,j)./max(1,C50a./0.3);

       
       h = fspecial('motion',20 , tat+90); %%%% !!!! to norm~~~!!!

       LIContrastORI(:,:,j) = imfilter(min(C50,ContrastORI(:,:,j)*3),h,'replicate');
       LIContrastORI(:,:,j) = min(C50,LIContrastORI(:,:,j))+ContrastORI(:,:,j)*(1-C50);
%        figure;  imagesc( LIContrastORI(:,:,j)); colormap gray
       
%        imagesc( LIContrastORI(:,:,j));
%        LIContrastORI(:,:,j) = ContrastORI(:,:,j)+0.25*LI;
       outS = max(outS,ContrastORI(:,:,j));
       LIoutS = max(LIoutS,LIContrastORI(:,:,j));
    end
%     
    if(i>1)
        
        se2 = strel('diamond',i);
        outS = imerode(outS,se2);
        LIoutS = imerode(LIoutS,se2);
    end
       out = max(outS,out);
       LIout = max(LIoutS,LIout);

end
% 
% size1=4*size1;
% out = out(size1:(end-size1),size1:(end-size1));
% LIout = LIout(size1:(end-size1),size1:(end-size1));

nurmOUT = max(out(:));
out = out/nurmOUT;
dd=min(1,LIout./max(LIout(:)));
LIout = max(out,dd);

% % 
% % % figure; imagesc(out.^(1/nSCL));colormap gray;
%  figure; imagesc(out.^1);colormap gray;
%  figure; imagesc(LIout.^1);colormap gray;


