function sys = inv(sys,method)
%INV  Inverse LTI model.
%
%   ISYS = INV(SYS) computes the inverse model ISYS such that
%
%       y = SYS * u   <---->   u = ISYS * y 
%
%   The LTI model SYS must have the same number of inputs and
%   outputs.
%
%   For arrays of LTI models, INV is performed on each individual
%   model.
%   
%   See also MLDIVIDE, MRDIVIDE, LTIMODELS.

%     Users can supply their own inversion method with the
%     syntax  INV(SYS,METHOD).  For instance, 
%         isys = inv(sys,'myway')
%     executes
%         [isys.z,isys.p,isys.k] = myway(sys.z,sys.p,sys.k)
%     to perform the inversion.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.12 $

% Effect on other properties: exchange Input/Output Names
% Everything else is blown away

sizes = size(sys.k);
ny = sizes(1);  
nu = sizes(2);

% Error checking and quick exits
if any(sizes==0),
   sys = sys.';  
   return
elseif ny~=nu,
   error('Cannot invert non-square system.');
elseif nargin>1,
  % User-supplied method
  [sys.z,sys.p,sys.k] = feval(method,sys.z,sys.p,sys.k);
  sys.lti = inv(sys.lti);
  return
elseif hasdelay(sys)
   Ts = getst(sys);
   if Ts,
      % Map delay times to poles at z=0 in discrete-time case
      sys = delay2z(sys);
   else
      error('Inverse of delay system is non causal.')
   end   
end


% Compute inverse
if ny>1,
  % MIMO system: let ss/inv handle it
  if ~isproper(sys),
     error('Inversion of non proper MIMO systems not available');
  end

  % Convert to state space and then invert
  try 
     sys = zpk(inv(ss(sys)));
  catch
     error('Cannot invert MIMO transfer functions with strictly proper channels.');
  end
  
else
  % SISO system
  [z,p,k] = zpkdata(sys);
  if k==0,
     error('Cannot invert ZPK models with zero gain.')
  end
  
  sys.z = p;
  sys.p = z;
  sys.k = 1/k;
  sys.lti = inv(sys.lti);
end

