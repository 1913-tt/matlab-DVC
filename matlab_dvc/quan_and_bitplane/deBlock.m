function [out] = deBlock(im,n)
%·Ö¿é
%   
s=size(im);
out=zeros(n,n,s(1)*s(2)/n^2);
for i=1:n:s(1)
    for j=1:n:s(2)
%         imshow(im(i:i+n-1,j:j+n-1));
%        out(:,:,((i-1)/n)*s(2)/n+(j-1)/n+1)=im(i:i+n-1,j:j+n-1);
        out(:,:,((i-1)/n)+((j-1)/n)*s(1)/n+1)=im(i:i+n-1,j:j+n-1);
    end
end


end

