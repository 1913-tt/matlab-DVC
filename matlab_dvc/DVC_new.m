clear ;% clc;
 %tic; t0 = cputime; 
addpath('matlabPyrTools');
addpath('matlabPyrTools/Mex');
addpath('keyF');
addpath('LDPCA');
t0 = clock;
row=144;col=176; %图像的高、宽
frames=5; % 序列的帧数  输入奇数 
Qp=24;      %H.264量化参数
gop=2;      %gop
iQ=4;        %量化矩阵
seq='hall_qcif';  %序列名称
%% key帧编码
keyFcfg='jm\\lencod3.exe -d jm\\encoder_intra_main.cfg ';
keyFcfg=[keyFcfg,'-p InputFile= \"yuv//',seq,'.yuv\" '];
keyFcfg=[keyFcfg,'-p ReconFile= \"keyF//',seq,'_out.yuv\" '];
keyFcfg=[keyFcfg,'-p FramesToBeEncoded= \"',int2str((frames+1)/gop),'\" '];
keyFcfg=[keyFcfg,'-p QPISlice= \"',int2str(Qp),'.yuv\" '];
keyFcfg=[keyFcfg,'-p FrameSkip= \"',int2str(gop-1),'.yuv\" '];
keyFcfg=[keyFcfg,'-p SourceWidth= \"',int2str(col),'.yuv\" '];
keyFcfg=[keyFcfg,'-p SourceHeight= \"',int2str(row),'.yuv\" '];
keyFcfg=[keyFcfg,'-p Grayscale= \"',int2str(1),'.yuv\" '];
keyFcfg=[keyFcfg,'  > jm.log'];
system(keyFcfg);
fprintf("key帧编码完毕\n");
%%

vidY=readyuv(['yuv/',seq,'.yuv'],frames,row,col);
keyF=readyuv(['keyF/',seq,'_out.yuv'],(frames+1)/gop,row,col);
out=zeros([row,col,(frames-1)/2],'uint8');
p_big=zeros(1,(frames-1)/2);
SIpsnr=zeros(1,(frames-1)/2);
avgbitrate=0;
for frame=1:(frames-1)/gop
 
 
      [out(:,:,frame),bitrate,SIpsnr(frame)]=DVCcodec(keyF(:,:,frame),keyF(:,:,frame+1),vidY(:,:,frame*2),frame*2,iQ);

       avgbitrate=avgbitrate+bitrate;
       int_y=vidY(:,:,frame*2); 
       p_big(frame)=psnr(out(:,:,frame),int_y);
       fprintf("F%d: WZpsnr:%f  SIpsnr:%f  bitrate:%f\n",frame*2,p_big(frame),SIpsnr(frame),bitrate);


end
avgbitrate=avgbitrate/((frames-1)/gop);

time = etime(clock, t0);
p_big_avg=mean(p_big);
SIpsnr_avg=mean(SIpsnr);
fprintf("\n avgPSNR:%f  bitrate:%f  SI-PSNR:%f   time:%f \n",p_big_avg,avgbitrate,SIpsnr_avg,time)
figure;
plot(p_big,'b');
legend('PSNR');title(seq);