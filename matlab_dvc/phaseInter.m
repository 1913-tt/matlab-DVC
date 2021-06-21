%% Phase Based View Interpolation
% This is a personal reimplementation by Oliver Wang: oliver.wang2@gmail.com
% It is written for clarity and is highly unoptimized.
% Note: see README before using!!!
function out=phaseInter(im1,im2,im3)

%re=imread(['G:\phase-based\out1\hall_qcif\re\re',int2str(f),'.png']);



addpath('matlabPyrTools');
addpath('matlabPyrTools/Mex');

%% parameters
[h,w] = size(im1);

% Number of frames to interpolate
params.nFrames = 1;

% Number of orientations in the steerable pyramid (more = more accurate but slower)
params.nOrientations = 16;

% Width of transition region
params.tWidth = 1;

% Steepness of the pyramid (smaller = slower)
params.scale = 0.5^(1/4);

% Maximum allowed shift in radians (larger = more motion, but more
% artifacts)£¨0-1£©
params.limit = 0.4;

% Number of levels of the pyramid
params.min_size = 15;
params.max_levels = 23;

params.nScales = min(ceil(log2(min([h w]))/log2(1/params.scale) - ...
    (log2(params.min_size)/log2(1/params.scale))),params.max_levels);
 params.nScales = 18;


%% Decompose images using steerable pyramid
L = decompose(im1,params);
R = decompose(im2,params);
% Re = decompose(re,params);
%% Compute shift corrected phase difference
% phase_diff = computePhaseDifference(L.phase, R.phase, L.pind, params);
phase_diff = computePhaseDifference(L.phase, R.phase, L.pind, params);

%% Generate inbetween images
step = 1/(params.nFrames+1);
out=zeros([h,w,params.nFrames],'uint8');
for f=1:params.nFrames
    alpha = step*f;
    
    % interpolate the pyramid
    inter_pyr = interpolatePyramid(L, R, phase_diff, alpha);
    %inter_pyr = interpolatePyramid(L, R,M, phase_diff, alpha);
    
    % reconstruct the image from steerable pyramid
    recon_image = reconstructImage(inter_pyr,params,L.pind);
    
    out(:,:,f) = (recon_image);
end


%end
