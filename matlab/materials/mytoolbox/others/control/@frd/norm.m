function [ltinorm,fpeak] = norm(sys,type,tol)
%NORM  LTI system norms.
%
%   NORM(SYS) is the root-mean-squares of the impulse response of 
%   the LTI model SYS, or equivalently the H2 norm of SYS.
%
%   NORM(SYS,2) is the same as NORM(SYS).
%
%   NORM(SYS,inf) is the infinity norm of SYS, i.e., the peak gain
%   of its frequency response (as measured by the largest singular 
%   value in the MIMO case).
%
%   NORM(SYS,inf,TOL) specifies a relative accuracy TOL for the 
%   computed infinity norm (TOL=1e-2 by default).
%       
%   [NINF,FPEAK] = NORM(SYS,inf) also returns the frequency FPEAK
%   where the gain achieves its peak value NINF.
%
%   For a S1-by...-by-Sp array SYS of LTI models, NORM returns an
%   array N of size [S1 ... Sp] such that
%      N(j1,...,jp) = NORM(SYS(:,:,j1,...,jp)) .  
%
%   See also SIGMA, FREQRESP, LTIMODELS.

%  Reference:
%      Bruisma, N.A., and M. Steinbuch, ``A Fast Algorithm to Compute
%      the Hinfinity-Norm of a Transfer Function Matrix,'' Syst. Contr. 
%      Letters, 14 (1990), pp. 287-293.

%   Author(s): P. Gahinet, S. Almy
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 1998/08/25 22:08:28 $

ni = nargin;
error(nargchk(1,3,ni))
if ni<2 | ~(isequal(type,Inf) | strncmpi('inf',type,min(length(type),3)))
   error('Only NORM(SYS,Inf) supported for FRD models.');
end

% Get sizes
sizes = [size(sys.ResponseData) 1 1];
nsys = prod(sizes(4:end));

ltinorm = zeros(sizes(4:end));
fpeak = zeros(sizes(4:end));

for k=1:nsys
   [sval,freq] = sigma(sys(:,:,nsys));
   [ltinorm(k),index] = max(sval(1,:));
   fpeak(k) = freq(index);
end

