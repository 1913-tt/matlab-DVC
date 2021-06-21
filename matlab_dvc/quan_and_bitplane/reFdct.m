function out = reFdct(dct,lowdct)
    len=size(lowdct,3);
    lowB=zeros(4,4,len);
    for n=1:len
        lowB(:,:,n)=idct2(lowdct(:,:,n));
    end
    lowF=reBlock_double(lowB,[72,88]);
    lows2=deBlock(lowF,2);
    lowdct=dct;
    outB=zeros(4,4,len*4);
    for n=1:len*4
        lowdct(1:2,1:2,n)=dct2(lows2(:,:,n));
        outB(:,:,n)=idct2(lowdct(:,:,n));
    end
    out=reBlock(outB,[144,176]);
    
end