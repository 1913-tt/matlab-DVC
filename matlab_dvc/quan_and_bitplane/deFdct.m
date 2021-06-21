function [outdct,lowF,lowFdct]=deFdct(input)
    inB=deBlock(input,4);
    len=size(inB,3);
    outdct=zeros(4,4,len);
    lowFpartdct=zeros(2,2,len);
    for n=1:len
        outdct(:,:,n)=dct2(double(inB(:,:,n)));
        lowFpartdct(:,:,n)=idct2(outdct(1:2,1:2,n));
    end
    lowF=reBlock_double(lowFpartdct,[72,88]);
    lowFs4=deBlock(lowF,4);
    lowFdct=zeros(4,4,size(lowFs4,3));
    for n=1:size(lowFs4,3)
            lowFdct(:,:,n)=dct2(lowFs4(:,:,n));
    end
end