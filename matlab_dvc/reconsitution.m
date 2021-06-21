function out=reconsitution(params,L,R,phase_diff,h,w,M)
step = 1/(params.nFrames+1);
out=zeros([h/2,w/2,params.nFrames],'uint8');
% out=zeros([h,w,params.nFrames],'uint8');
for f=1:params.nFrames
    alpha = step*f;
    
    % interpolate the pyramid
    inter_pyr = interpolatePyramid(L, R, phase_diff, alpha,M);
    %inter_pyr = interpolatePyramid(L, R,M, phase_diff, alpha);
    
    % reconstruct the image from steerable pyramid
    recon_image = reconstructImage(inter_pyr,params,L.pind);
    
    out(:,:,f) = small(recon_image);
%     out(:,:,f) = (recon_image);
end