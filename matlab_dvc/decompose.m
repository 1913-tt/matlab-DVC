%% Phase Based View Interpolation
% This is a personal reimplementation by Oliver Wang: oliver.wang2@gmail.com
% Note: see README before using!!! 

function decomposition = decompose(im,params)


im = im2single(im);
im_dims = size(im);


% Build the pyramid   %pyr是将所有的金字塔放一起啦 包含了总的层数和迭代次数   pind就是每个金字塔的尺寸
[pyr, pind] = buildSCFpyr_scale(im,params.nScales,...
    params.nOrientations-1,params.tWidth,params.scale,...
    params.nScales,im_dims);

% Store decomposition residuals
high_pass = spyrHigh(pyr,pind); %这里将金字塔取出来了  取得第一个
%
%     figure;imshow(abs(high_pass)*100);
low_pass = pyrLow(pyr,pind);     %这里将金字塔取出来了  取得最后一个
decomposition.high_pass = high_pass(:);
decomposition.low_pass = low_pass(:);

% Store decomposition phase and magnitudes
pyr_levels = pyr(numel(high_pass)+1:numel(pyr)-numel(low_pass)); %去头去尾       
decomposition.phase = angle(pyr_levels);
decomposition.amplitude= abs(pyr_levels);  

% Store indices (same every channel)
decomposition.pind = pind;



end

