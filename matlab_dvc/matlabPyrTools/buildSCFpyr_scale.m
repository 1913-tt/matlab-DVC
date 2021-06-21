% [PYR, INDICES, STEERMTX, HARMONICS] = buildSCFpyr(IM, HEIGHT, ORDER, TWIDTH)
%
% This is a modified version of buildSFpyr, that constructs a
% complex-valued steerable pyramid  using Hilbert-transform pairs
% of filters.  Note that the imaginary parts will *not* be steerable.
%这是buildSFpyr的一个修改版本，它使用Hilbert-transform对过滤器构造一个复值可操纵金字塔。请注意，虚部将*不*是可操纵的。
% To reconstruct from this representation, either call reconSFpyr
% on the real part of the pyramid, *or* call reconSCFpyr which will
% use both real and imaginary parts (forcing analyticity).
%要从这个表示重建，要么调用金字塔的实部的reconSFpyr， *或*调用将使用实部和虚部(强制分析性)的reconSCFpyr。
% Description of this transform appears in: Portilla & Simoncelli,
% Int'l Journal of Computer Vision, 40(1):49-71, Oct 2000.
% Further information: http://www.cns.nyu.edu/~eero/STEERPYR/

% Original code: Eero Simoncelli, 5/97.
% Modified by Javier Portilla to return complex (quadrature pair) channels,
% 9/97.
% Further modified to use a different pyramid steepness (Scale) - owang
                                                  %图像 金字塔层数 迭代次数 插帧数 金字塔差 金字塔层数 图像尺寸
function [pyr,pind,steermtx,harmonics] = buildSCFpyr_scale(im, ht, order, twidth, scale, nScales, im_dims)

%-----------------------------------------------------------------
%% DEFAULTS:检查输入数据
if (exist('order') ~= 1)
  order = 3;
elseif ((order > 63)  | (order < 0))
  fprintf(1,'Warning: ORDER must be an integer in the range [0,15]. Truncating.\n');
  order = min(max(order,0),63);
else
  order = round(order);
end
nbands = order+1;%迭代次数

if (exist('twidth') ~= 1)
  twidth = 1;
elseif (twidth <= 0)
  fprintf(1,'Warning: TWIDTH must be positive.  Setting to 1.\n');
  twidth = 1;
end

if (exist('scale') ~= 1)
  scale = 0.5;
end

%-----------------------------------------------------------------
%% Steering stuff:

if (mod((nbands),2) == 0)
  harmonics = [0:(nbands/2)-1]'*2 + 1;
else
  harmonics = [0:(nbands-1)/2]'*2;
end

steermtx = steer2HarmMtx(harmonics, pi*[0:nbands-1]/nbands, 'even');%a map???

%-----------------------------------------------------------------

dims = size(im);
ctr = ceil((dims+0.5)/2);%%这是要干什么

%%二维/三维空间的笛卡尔网格   xramp  yramp 对应xy网格坐标
[xramp,yramp] = meshgrid( ([1:dims(2)]-ctr(2))./(dims(2)/2), ...
    ([1:dims(1)]-ctr(1))./(dims(1)/2) );
angle = atan2(yramp,xramp);  %每个网格点的角度（四象限）
log_rad = sqrt(xramp.^2 + yramp.^2);  %每个网格的幅度
log_rad(ctr(1),ctr(2)) =  log_rad(ctr(1),ctr(2)-1);
log_rad  = log2(log_rad);

%% Radial transition function (a raised cosine in log-frequency):
[Xrcos,Yrcos] = rcosFn(twidth,(-twidth/2),[0 1]);   %%x=-1-0   y=0-1   Xrcos   Yrcos=cos(X)^2
Yrcos = sqrt(Yrcos);

YIrcos = sqrt(1.0 - Yrcos.^2);   %sin(X)??
lo0mask = pointOp(log_rad, YIrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);%% 返回了一个矩阵  矩阵中椭圆之外的东西滤除

imdft = fftshift(fft2(im));

lo0dft =  imdft .* lo0mask;   %这里为什么要整个什么升余弦  不直接矩形一下呢   这样对接下来的运算不会有影响吗

[pyr,pind] = buildSCFpyrLevs_scale(lo0dft, log_rad, Xrcos, Yrcos, angle, ht, nbands, scale, nScales, im_dims);

hi0mask = pointOp(log_rad, Yrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
hi0dft =  imdft .* hi0mask;
hi0 = ifft2(ifftshift(hi0dft));

pyr = [real(hi0(:)) ; pyr];
pind = [size(hi0); pind];
