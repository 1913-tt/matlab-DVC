function q = myUnwrap(p,cutoff,dim)%【纠错后   纠错前】  空 2

ni = nargin;%%nargin是该函数输入参数的个数

% Treat row vector as a column vector (unless DIM is specified)
rflag = 0;
if ni<3 && (ndims(p)==2) && (size(p,1)==1), 
   rflag = 1; 
   p = p.';
end

% Initialize parameters.
nshifts = 0;
perm = 1:ndims(p);
switch ni
case 1
   [p,nshifts] = shiftdim(p);
   cutoff = pi;
case 2
   [p,nshifts] = shiftdim(p);
otherwise    % nargin == 3
   perm = [dim:max(ndims(p),dim) 1:dim-1];
   p = permute(p,perm);
   if isempty(cutoff)
      cutoff = pi; 
   end
end
   
% Reshape p to a matrix.
siz = size(p);
p = reshape(p, [siz(1) prod(siz(2:end))]);

% Unwrap each column of p
q = LocalUnwrap(p,cutoff);

% Reshape output
q = reshape(q,siz);
q = ipermute(q,perm);
%此 MATLAB 函数 将 X 的维度移动 n。当 n 为正数时，shiftdim 向左移动这些维度并将前面 n 个维绕回到末尾。当 n
%为负数时，shiftdim 向右移动维度并使用单一维度进行填充。
q = shiftdim(q,-nshifts);
if rflag, 
   q = q.'; 
end

function p = LocalUnwrap(p,cutoff)

dp = p(2,:) - p(1,:);            % Incremental phase variations
dps = mod(dp+pi,2*pi) - pi;      % Equivalent phase variations in [-pi,pi)
dps(dps==-pi & dp>0,:) = pi;     % Preserve variation sign for pi vs. -pi
dp_corr = dps - dp;              % Incremental phase corrections
dp_corr(abs(dp)<cutoff) = 0;   % Ignore correction when incr. variation is < CUTOFF

% Integrate corrections and add to P to produce smoothed phase values
p(2,:) = p(2,:) + dp_corr;   %将差降低当pi以内