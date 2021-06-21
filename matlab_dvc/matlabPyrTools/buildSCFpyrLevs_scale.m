% [PYR, INDICES] = buildSCFpyrLevs(LODFT, LOGRAD, XRCOS, YRCOS, ANGLE, HEIGHT, NBANDS)
%
% Recursive function for constructing levels of a steerable pyramid.  This
% is called by buildSCFpyr, and is not usually called directly.

% Original code: Eero Simoncelli, 5/97.
% Modified by Javier Portilla to generate complex bands in 9/97.
% 
% Further modified to use a different pyramid steepness (Scale) - owang
                                     %�任���im                   �����Ӧ�ĽǶ�
function [pyr,pind] = buildSCFpyrLevs_scale(lodft,log_rad,Xrcos,Yrcos,angleI, ht,nbands,scale,nScales,im_dims)

if (ht <= 0)

  lo0 = ifft2(ifftshift(lodft));
  pyr = real(lo0(:));
  pind = size(lo0);

else

  bands = zeros(prod(size(lodft)), nbands);
  bind = zeros(nbands,2);

%  log_rad = log_rad + 1;
  %Xrcos = Xrcos - log2(2);  % shift origin of lut by 1 octave.
  Xrcos = Xrcos - log2(1/scale); %new

  lutsize = 1024;
  Xcosn = pi*[-(2*lutsize+1):(lutsize+1)]/lutsize;  % [-2*pi:pi]
  order = nbands-1;
  %% divide by sqrt(sum_(n=0)^(N-1)  cos(pi*n/N)^(2(N-1)) )
  %% Thanks to Patrick Teo for writing this out :)
  const = (2^(2*order))*(factorial(order)^2)/(nbands*factorial(2*order));%factorial����ײ�

%
%  Ycosn = sqrt(const) * (cos(Xcosn)).^order;
%
  % analityc version: only take one lobe
  alfa=	mod(pi+Xcosn,2*pi)-pi;
  Ycosn = 2*sqrt(const) * (cos(Xcosn).^order) .* (abs(alfa)<pi/2);

  himask = pointOp(log_rad, Yrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
    
  for b = 1:nbands
    anglemask = pointOp(angleI, Ycosn, Xcosn(1)+pi*(b-1)/nbands, Xcosn(2)-Xcosn(1));%%ѡ��Ƕȣ���
    banddft = ((-1i)^(nbands-1)) .* lodft .* anglemask .* himask;
    
    if ht==1&&b==1
%         disp(banddft);
    end
    %figure;imshow(banddft)
    band = ifft2(ifftshift(banddft));
    %phase = angle(band);
    %amplitude = abs(band);
    %phase = applyWindowing(phase,0,0,0);
    %band = amplitude.*exp(1i*phase);
    
%    bands(:,b) = real(band(:));
    % analytic version: full complex value
    bands(:,b)=band(:);
%     if ht==10  
%         figure;imshow(angle((band)));
% %         figure;imshow(abs(band)*100);
%     end
%     if ht==1
%       figure;imshow(angle((band)));
%     end
    bind(b,:)  = size(band);
    
    %figure;imshow(anglemask .* himask);
    %figure;imshow(abs(band)*100);
  end

  dims = size(lodft);
  ctr = ceil((dims+0.5)/2);
  
  %compute lodims always from highest level  
  lodims = round(im_dims(1:2)*scale^(nScales-ht+1)); %������һ�εĴ�С
  
  loctr = ceil((lodims+0.5)/2);
  lostart = ctr-loctr+1;
  loend = lostart+lodims-1;

  log_rad = log_rad(lostart(1):loend(1),lostart(2):loend(2));%��ôֱ�ӾͰѱ߱߼�����
  angleI = angleI(lostart(1):loend(1),lostart(2):loend(2));
  lodft = lodft(lostart(1):loend(1),lostart(2):loend(2));
  YIrcos = abs(sqrt(1.0 - Yrcos.^2));
  lomask = pointOp(log_rad, YIrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
  %
%   if ht==1
%       figure;imshow(lomask);
%   end
  %
  lodft = lomask .* lodft;

  [npyr,nind] = buildSCFpyrLevs_scale(lodft, log_rad, Xrcos, Yrcos, angleI, ht-1, nbands, scale, nScales, im_dims);

  pyr = [bands(:); npyr];
  pind = [bind; nind];

end

