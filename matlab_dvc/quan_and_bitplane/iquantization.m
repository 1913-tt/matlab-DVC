function out=iquantization(quan,quantRanges,SI)
quan=quan+1;
out=zeros(1,length(quan));
for i=1:length(quan)
    j=quan(i);
    if SI(i)>quantRanges(j)&&SI(i)<quantRanges(j+1)
        out(i)=SI(i);
    else
        out(i)=(quantRanges(j)+quantRanges(j+1))/2;
    end
end


end