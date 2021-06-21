function [outimg,bitrate,SIpsnr]=DVCcodec(im1,im2,im3,frame,iQ)

addpath('quan_and_bitplane');
addpath('LDPCA');
ladderFile = '24_1584.lad';
% QLevels={[7,6,5,4;6,5,4,3;5 ,4,3,2;4,3,2,0],[6,5,4,3;5,4,3,2;4,3,2,2;3,2,2,0],[6,4,3,3;4,3,3,2;3,3,2,2;3,2,2,0],[5,4,3,2;4,3,2,2;3,2,2,0;2,2,0,0],...
%     [5,4,3,2;4,3,2,0;3,2,0,0;2,0,0,0],[5,3,2,0;3,2,0,0;2,0,0,0;0,0,0,0],[5,3,0,0;3,0,0,0;0,0,0,0;0,0,0,0],[4,3,0,0;3,0,0,0;0,0,0,0;0,0,0,0]};
QLevels={[4,3,0,0;3,0,0,0;0,0,0,0;0,0,0,0],[5,3,0,0;3,0,0,0;0,0,0,0;0,0,0,0],[5,3,2,0;3,2,0,0;2,0,0,0;0,0,0,0],...
    [5,4,3,2;4,3,2,0;3,2,0,0;2,0,0,0],[5,4,3,2;4,3,2,2;3,2,2,0;2,2,0,0],[6,4,3,3;4,3,3,2;3,3,2,2;3,2,2,0],...
    [6,5,4,3;5,4,3,2;4,3,2,2;3,2,2,0],[7,6,5,4;6,5,4,3;5,4,3,2;4,3,2,0]};
order=[1,1;1,2;2,1;3,1;2,2;1,3;1,4;2,3;3,2;4,1;4,2;3,3;2,4;3,4;4,3;4,4];


SI=phaseInter(im1,im2,im3);

SIpsnr=psnr(im3,SI);

SIblocks=deBlock(SI,4);
im3blocks=deBlock(im3,4);
quanmatrix=QLevels{iQ};
framerate=15;
len=size(SIblocks,3);
SIdct=zeros(4,4,len); 
im3dct=zeros(4,4,len);
 for n=1:len
        SIdct(:,:,n)=dct2(double(SIblocks(:,:,n)));
        im3dct(:,:,n)=dct2(double(im3blocks(:,:,n)));
 end
endctquan=zeros(16,len);
residual=(double(im1)-double(im2))/2;
alphas=correlationNoiseModeling(residual,len);
allbit=0;allerr=0;
rebit=zeros(16,len);
rebands=zeros(4,4,len);
for nf=1:16
    if quanmatrix(order(nf,1),order(nf,2))==0
        rebands(order(nf,1),order(nf,2),:)=SIdct(order(nf,1),order(nf,2),:);
        continue;
    end
    if nf==1
        enqR=DCquantRanges(im3dct(order(nf,1),order(nf,2),:),quanmatrix(order(nf,1),order(nf,2)));
    else
        enqR=quantRanges(im3dct(order(nf,1),order(nf,2),:),quanmatrix(order(nf,1),order(nf,2)));
    end
    endctquan(nf,:)=quantizer(im3dct(order(nf,1),order(nf,2),:),enqR);

    enbitplane=bit_plane(endctquan(nf,:),quanmatrix(order(nf,1),order(nf,2)));

    accumSyndrome=zeros(quanmatrix(order(nf,1),order(nf,2)),len);

    for nb=1:quanmatrix(order(nf,1),order(nf,2))
        accumSyndrome(nb,:) = encodeBits(double(enbitplane(nb,:)), ladderFile);
    end
     [out,bit,biterr]=LDPCAdecoder(alphas(nf,:),accumSyndrome,double(enbitplane),ladderFile,enqR,SIdct(order(nf,1),order(nf,2),:));
    
     allbit=allbit+bit;
     allerr=allerr+biterr;
     rebit(nf,:)=re_bit_plane(out,quanmatrix(order(nf,1),order(nf,2)));

     rebands(order(nf,1),order(nf,2),:)=iQuanter(rebit(nf,:),enqR,SIdct(order(nf,1),order(nf,2),:),alphas(nf,:));

end
bitrate=allbit/1024*framerate;
re=zeros(4,4,len);
for n=1:len
      re(:,:,n)=idct2(double(rebands(:,:,n)));
end
reim=reBlock(re,[144,176]);
psnr(reim,im3);
outimg=reim;

end