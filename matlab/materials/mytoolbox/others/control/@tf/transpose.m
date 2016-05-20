function tsys = transpose(sys)
%TRANSPOSE  Transposition for transfer functions.
%
%   TSYS = TRANSPOSE(SYS) is invoked by TSYS = SYS.'.
%
%   The numerator and denominator of SYS and TSYS are 
%   related by
%       TSYS.NUM = SYS.NUM.'
%       TSYS.DEN = SYS.DEN.'
%
%   If SYS represents the transfer function H(s) or H(z),
%   then TSYS represents the transfer function H(s).' 
%   (respectively, H(z).' in the discrete-time case).
%
%   See also CTRANSPOSE, TF, LTIMODELS.

%   Author(s): P.Gahinet, 4-1-96
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 1998/02/12 22:28:30 $

tsys = sys;

% Transpose NUM and DEN
sizes = size(sys.num);
sizes([1 2]) = sizes([2 1]);
tsys.num = cell(sizes);
tsys.den = cell(sizes);

for k=1:prod(sizes(3:end)),
   tsys.num(:,:,k) = sys.num(:,:,k)';
   tsys.den(:,:,k) = sys.den(:,:,k)';
end

tsys.lti = (sys.lti).';


