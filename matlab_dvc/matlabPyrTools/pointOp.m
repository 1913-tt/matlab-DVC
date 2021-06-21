% RES = pointOp(IM, LUT, ORIGIN, INCREMENT, WARNINGS)
%
% Apply a point operation, specified by lookup table LUT, to image IM.
% LUT must be a row or column vector, and is assumed to contain
% (equi-spaced) samples of the function.  ORIGIN specifies the
% abscissa associated with the first sample, and INCREMENT specifies the
% spacing between samples.  Between-sample values are estimated via
% linear interpolation.  If WARNINGS is non-zero, the function prints
% a warning whenever the lookup table is extrapolated.
%
% This function is much faster than MatLab's interp1, and allows
% extrapolation beyond the lookup table domain.  The drawbacks are
% that the lookup table must be equi-spaced, and the interpolation is
% linear.
%对图像IM应用查找表LUT指定的点操作。LUT必须是行或列向量，并且假设包含函数的(等间距)样本。原点指定与第一个样本相关联的横坐标，
%增量指定样本之间的间隔。利用线性插值估计样本间的值。如果警告非零，则函数在外推查找表时输出一个警告。
%这个函数比MatLab的interp1快得多，并且允许在查找表域之外进行外推。缺点是查找表必须是等间距的，插值是线性的。
% Eero Simoncelli, 8/96.

function res = pointOp(im, lut, origin, increment, warnings)

%% NOTE: THIS CODE IS NOT ACTUALLY USED! (MEX FILE IS CALLED INSTEAD)

fprintf(1,'WARNING: You should compile the MEX version of "pointOp.c",\n         found in the MEX subdirectory of matlabPyrTools, and put it in your matlab path.  It is MUCH faster.\n');

X = origin + increment*[0:size(lut(:),1)-1];
Y = lut(:);

res = reshape(interp1(X, Y, im(:), 'linear', 'extrap'),size(im));%对im中对应的坐标按照X，Y进行插值

