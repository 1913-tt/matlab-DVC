function [out,bit,biterr]=LDPCAdecoder(alphas,accumSyndrome,source,ladderFile,quanRange,SIdct)

[nBitplane,len]=size(accumSyndrome);
decoded=zeros(nBitplane,len);
bit=0;biterr=0;
for i=1:nBitplane
    currentbitMask=2^(nBitplane-i);
    decodedbitMask = (length(quanRange)-2) - ((currentbitMask*2) - 1);
    p1=zeros(1,len);
    p0=zeros(1,len);
    DecodedCoeffs=re_bit_plane(decoded,nBitplane);
    for j=1:len
        p1(j)=1.175494351e-38;
        p0(j)=1.175494351e-38; 
        for level=0:(2^(nBitplane)-1)
            levelvalue=(quanRange(level+1)+quanRange(level+2))/2;
            if bitand(bitxor(level,DecodedCoeffs(j)),decodedbitMask)==0
                if bitand(level , currentbitMask)
                    p1(j)=p1(j)+(alphas(j)/2)*exp(-alphas(j)*abs(levelvalue-SIdct(j)));
                else
                    p0(j)=p0(j)+(alphas(j)/2)*exp(-alphas(j)*abs(levelvalue-SIdct(j)));
                end
            end
        end
    end
    pLLR=log(p0./p1);
    [decoded(i,:), rate, numErrors] = decodeBits( pLLR, accumSyndrome(i,:), source(i,:), ladderFile );
%     fprintf("%f ",rate);
    bit=bit+(rate*len);
    biterr=biterr+numErrors;
end
% fprintf("\n");
out=decoded;
end