function [out]=quantRanges(seq,q)
maxseq=max(abs(seq));
% disp(maxseq);
quanstep=2*maxseq/(2^q);
n=1;
out=zeros(1,2^q+1);
for i=-(floor(2^q/2.0)):-1
    out(n)=i*quanstep;
    n=n+1;
end
% out(n)=quanstep;
% n=n+1;
for i=1:((floor(2^q/2.0))+1)
    out(n)=i*quanstep;
    n=n+1;
end
% for i=(-2^(q-1)):2^(q-1)
%     out(n)=i*quanstep;
%     n=n+1;
% end

end