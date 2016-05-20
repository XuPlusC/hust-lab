function tsys = ctranspose(sys)
%CTRANSPOSE  Pertransposition of Frequency Response Data object.
%
%   TSYS = CTRANSPOSE(SYS) is invoked by TSYS = SYS'
%
%   If SYS represents the continuous-time transfer function
%   H(s), TSYS represents its pertranspose H(-s).' .   In 
%   discrete time, TSYS represents H(1/z).' if SYS represents 
%   H(z).
%
%   See also TRANSPOSE, FRD, LTIMODELS.

%   Author(s): S. Almy
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 1998/05/22 19:21:17 $

tsys = sys;

sysResponse = sys.ResponseData;

sizes = size(sysResponse);
sizes([1 2]) = sizes([2 1]);

response = zeros(sizes);

for k=1:prod(sizes(3:end))
   response(:,:,k) = sysResponse(:,:,k)';
end

tsys.ResponseData = response;

tsys.lti = (sys.lti)';