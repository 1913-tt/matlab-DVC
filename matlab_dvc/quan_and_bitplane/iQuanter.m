function out=iQuanter(quan,quantRanges,SI,alphas)
quan=quan+1;
out=zeros(1,length(quan));
for i=1:length(quan)
    j=quan(i);
    u=quantRanges(j+1);
    l=quantRanges(j);
    y=SI(i);
    delta=u-l;
    a=alphas(j);
    b=1/a+delta/(1-exp(a*delta));
    gamma=y-l;
    sigma=u-y;
    if(y<l)
        out(i)=l+b;
    elseif y>=u
    	out(i)=u-b;
    else
        out(i)=y;%+((gamma+1/a)*exp(-a*gamma)-(sigma+1)*exp(-a*delta))/(2-exp(-a*gamma)-exp(-a*sigma));
    end
end


end