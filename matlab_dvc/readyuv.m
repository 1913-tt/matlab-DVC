function out=readyuv(filename,n,row,col)
fid = fopen(filename,'r');
out=zeros([row,col,n],'uint8');
for frame=1:n
 %读入文件 将yuv转换为rgb，并用imshow显示
    im_l_y = zeros(row,col); %Y
    for i1 = 1:row 
       im_l_y(i1,:) = fread(fid,col);  %读取数据到矩阵中 
    end
    im_l_cb = zeros(row/2,col/2); %cb
    for i2 = 1:row/2 
       im_l_cb(i2,:) = fread(fid,col/2);
    end
    im_l_cr = zeros(row/2,col/2); %cr
    for i3 = 1:row/2 
       im_l_cr(i3,:) = fread(fid,col/2);  
    end
    out(:,:,frame)=im_l_y;
    
    


end
end