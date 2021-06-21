function [out]=quantizer(seq,quantRanges)
n=length(quantRanges);
out=zeros(1,length(seq),'uint8');
for i=1:length(seq)
%     if seq(i)>=quantRanges(n)
%         out(i)=n-1;
%         continue;
%     end
%     if seq(i)<quantRanges(1)
%         out(i)=1;
%         continue;
%     end
    for j=1:n-1
        if seq(i)>=quantRanges(j)&&seq(i)<quantRanges(j+1)
           out(i)=uint8(j); 
        end
    end
end
out=out-1;

end