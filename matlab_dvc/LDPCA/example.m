% Author:  David Varodayan (varodayan@stanford.edu)
% Date:    May 9, 2006

n = 1584;                            % blocklength
ladderFile = '396_regDeg3.lad';     % regular degree 3 codes
ladderFile = '24_1584.lad';
pCrossover = 0.0044;                  % BSC crossover probability
% load test
% nb=1;
% accumSyndrome = encodeBits(enbitplane(nb,:), ladderFile);
% pCond = (1-pCrossover).*(1-double(SIbitplane(nb,:))) + pCrossover.*double(SIbitplane(nb,:)); % P(source=0|sideinfo)
% LLR_intrinsic = log( pCond./(1-pCond) ); % log( P(source=0|sideinfo)/P(source=1|sideinfo) )
% [decoded, rate, numErrors] = decodeBits( LLR_intrinsic, accumSyndrome, double(enbitplane(nb,:)), ladderFile );

source = double(rand(1, n)>0.5);

accumSyndrome = encodeBits(source, ladderFile);
sideinfo_BSC = mod(source + double( rand(1, n)<pCrossover ), 2);
same=sum(source(:)==sideinfo_BSC(:))/length(source(:))

pCond = (1-pCrossover).*(1-sideinfo_BSC) + pCrossover.*sideinfo_BSC; % P(source=0|sideinfo)
LLR_intrinsic = log( pCond./(1-pCond) ); % log( P(source=0|sideinfo)/P(source=1|sideinfo) )

[decoded, rate, numErrors] = decodeBits( LLR_intrinsic, accumSyndrome, source, ladderFile );