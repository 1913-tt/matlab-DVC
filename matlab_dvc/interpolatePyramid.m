%% Phase Based View Interpolation
% This is a personal reimplementation by Oliver Wang: oliver.wang2@gmail.com
% Note: see README before using!!! 

% Interpolate the pyramid given a specific alpha value
function [out_pyr] = interpolatePyramid(L, R, phase_diff, alpha, M)
%function out_pyr = interpolatePyramid(L, R,M, phase_diff, alpha)

% Compute new phase

new_phase =  R.phase + (alpha-1)*phase_diff; %为什么这里不进行前后结合？？？\

% new_phase=M.phase;
%%%我这里改改
% opticalFlow = opticalFlowLK;
% estimateFlow(opticalFlow,L.amplitude);
% flowObj = estimateFlow(opticalFlow,R.amplitude);
% flow = double(cat(3,flowObj.Vx,flowObj.Vy));
% 
% % for each timestep, generate the inbetween image
% step = 1/(params.nFrames+1);
% for f=1:params.nFrames
%     alpha = step*f;
%     new_amplitude(:,:,:,f) = im2uint8(frameInterpFlow(im1,im2,flow,alpha));
% end
% new_lowpass = (1-alpha)*L.low_pass + alpha*R.low_pass;
% 
% %%%这里结束

% Blend amplitude and lowpass
new_amplitude = (1-alpha)*L.amplitude + alpha*R.amplitude;
%  new_amplitude=M.amplitude;
new_lowpass = (1-alpha)*L.low_pass + alpha*R.low_pass;
% new_lowpass = L.low_pass;
% Compute new pyramid
new_pyr = new_amplitude.*exp(1i*new_phase);
%new_pyr=zeros([length(new_amplitude(:,1)),3]);
% Using either left or right highpass
if alpha < 0.5
    high_pass = L.high_pass;
else
    high_pass = R.high_pass;
end
% new_lowpass=M.low_pass;
% new_lowpass=zeros([length(L.low_pass(:,1)),3]);
%h=288;w=352;
% h=144;w=176;
% hhh(:,:,1)=reshape(high_pass(:,1),h,w);hhh(:,:,2)=reshape(high_pass(:,2),h,w);hhh(:,:,3)=reshape(high_pass(:,3),h,w);
% figure;imshow(abs(hhh)*100);
% high_pass=M.high_pass;
% high_pass=zeros([length(L.high_pass(:,1)),3]);
%p=psnr(high_pass,M.high_pass)
out_pyr = [high_pass;new_pyr;new_lowpass];
end

