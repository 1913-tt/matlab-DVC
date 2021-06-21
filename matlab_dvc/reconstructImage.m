%% Phase Based View Interpolation
% This is a personal reimplementation by Oliver Wang: oliver.wang2@gmail.com
% Note: see README before using!!!

% reconstruct an image from the interpolated pyramid
function out_img = reconstructImage(pyr,param,pind)

% imSize = pind(1,:);
% out_img = zeros(imSize(1),imSize(2));

% reconstruct each color channel
    out_img = reconSCFpyr_scale(pyr, pind, ...
        'all', 'all', param.tWidth, param.scale, param.nScales);


% convert to RGB
out_img = im2uint8(out_img);

end

