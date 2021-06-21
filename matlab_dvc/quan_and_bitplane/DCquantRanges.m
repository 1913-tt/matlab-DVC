function [out]=DCquantRanges(seq,q)
maxseq=1024;
% maxseq=ceil(max(seq));
quanstep=maxseq/(2^q);
n=1;
out=zeros(1,2^q+1);
for i=0:2^q
    out(n)=i*quanstep;
    n=n+1;
end

end