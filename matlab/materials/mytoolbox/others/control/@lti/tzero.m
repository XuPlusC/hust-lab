function varargout = tzero(sys)
%TZERO  Transmission zeros of LTI systems.
% 
%   Z = TZERO(SYS) returns the transmission zeros of the LTI 
%   system SYS.
%
%   [Z,GAIN] = TZERO(SYS) also returns the transfer function 
%   gain if the system is SISO.
%   
%   Z = TZERO(A,B,C,D) works directly on the state space matrices
%   and returns the transmission zeros of the state-space system:   
%           .
%           x = Ax + Bu     or   x[n+1] = Ax[n] + Bu[n]
%           y = Cx + Du           y[n]  = Cx[n] + Du[n]
%
%   See also ZERO, PZMAP, POLE.

%   Clay M. Thompson  7-23-90, 
%       Revised: P.Gahinet 5-15-96
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 1998/07/16 20:06:27 $

nout = max(1,nargout);
try
   [varargout{1:nout}] = zero(sys);
catch
   error(lasterr)
end

