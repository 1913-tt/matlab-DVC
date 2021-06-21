function result=psnr(in1,in2)

z=mse(in1,in2);

result=10*log10(255.^2/z);