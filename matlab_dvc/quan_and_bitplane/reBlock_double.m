function [out] = reBlock_double(b,s)
%øÈ÷ÿππ
n=size(b,1);
out=zeros(s(1),s(2));
for i=1:n:s(1)
    for j=1:n:s(2)
%        out(i:i+n-1,j:j+n-1)=b(:,:,((i-1)/n)*s(2)/n+(j-1)/n+1);
        out(i:i+n-1,j:j+n-1)=b(:,:,((i-1))/n+(j-1)/n*s(1)/n+1);
    end
end


end

