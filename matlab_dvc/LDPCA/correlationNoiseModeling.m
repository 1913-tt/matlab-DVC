function alphas=correlationNoiseModeling(residual,len)
%相关噪声建模
resiblock=deBlock(residual,4);
order=[1,1;1,2;2,1;3,1;2,2;1,3;1,4;2,3;3,2;4,1;4,2;3,3;2,4;3,4;4,3;4,4];
residct=zeros(4,4,len);
for n=1:len
    residct(:,:,n)=abs(dct2(double(resiblock(:,:,n))));
end
%resiCoeffs=zeros(16,len);
BandsMean=zeros(1,16);
BandsVariance=zeros(1,16);
%计算残差的每个频带的均值和方差
for n=1:16
    %resiCoeffs(n,:)=residct(order(nf,1),order(nf,2),:);
    BandsMean(n)=mean(residct(order(n,1),order(n,2),:));
    BandsVariance(n)=mean((residct(order(n,1),order(n,2),:)).^2);%var(residct(order(nf,1),order(nf,2),:));
end
BandsVariance=BandsVariance-(BandsMean.^2);
DistCoeffs=zeros(16,len);
for n=1:16
    DistCoeffs(n,:)=int32((residct(order(n,1),order(n,2),:)-BandsMean(n)).^2);
end
%计算拉普拉斯变换参数α
alphas=zeros(16,len);
for i=1:16
    for j=1:len
        if DistCoeffs(i,j)<BandsVariance(i)
            alphas(i,j)=sqrt(2/BandsVariance(i));
        else
            alphas(i,j)=sqrt(2/DistCoeffs(i,j));
        end
    end
end 


end