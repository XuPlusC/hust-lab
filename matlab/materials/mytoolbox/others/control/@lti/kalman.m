function [kest,l,p,m,z] = kalman(sys,qn,rn,nn,sensors,known)
%KALMAN  Continuous or discrete Kalman estimator
%
%   [KEST,L,P] = KALMAN(SYS,Qn,Rn,Nn) designs a Kalman estimator 
%   KEST for the continuous or discrete plant with state-space 
%   model SYS.  For a continuous plant
%        .
%        x = Ax + Bu + Gw            {State equation}
%        y = Cx + Du + Hw + v        {Measurements}
%
%   with known inputs u, process noise w, measurement noise v, and
%   noise covariances
%
%        E{ww'} = Qn,     E{vv'} = Rn,     E{wv'} = Nn,
%
%   the estimator KEST has input [u;y] and generates optimal 
%   estimates y_e,x_e of y,x by:
%          .
%         x_e  = Ax_e + Bu + L(y - Cx_e - Du)
%
%        |y_e| = | C | x_e + | D | u
%        |x_e|   | I |       | 0 | 
%
%   Type HELP DKALMAN for details on the discrete-time counterpart.
%
%   The state-space model SYS contains the plant data (A,[B G],C,[D H]),
%   and Nn is set to zero when omitted.  The Kalman estimator KEST
%   is continuous when SYS is continuous, discrete otherwise.
%   Also returned are the estimator gain L and the steady-state 
%   error covariance P.  In continuous time with H=0, P solves the 
%   Riccati equation
%                             -1
%        AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 .
%
%
%   [KEST,L,P] = KALMAN(SYS,Qn,Rn,Nn,SENSORS,KNOWN) handles more 
%   general plants SYS where the known and stochastic inputs u,w 
%   are mixed together, and not all outputs are measured.  The 
%   index vectors SENSORS and KNOWN then specify which outputs y 
%   of SYS are measured and which inputs u are known.  All other 
%   inputs are assumed stochastic.
%
%   See also KALMD, ESTIM, LQGREG, CARE, DARE, SS, LTIMODELS.

%   Author(s): P. Gahinet  8-1-96
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1998/07/16 20:50:21 $

ni = nargin;
error(nargchk(3,6,ni))
if ~isa(sys,'ss'),
   error('SYS must be a state-space LTI model.')
elseif hasdelay(sys),
   if sys.Ts,
      % Map delay times to poles at z=0 in discrete-time case
      sys = delay2z(sys);
   else
      error('Not supported for continuous-time delay systems.')
   end
elseif ni==3 | isempty(nn) | isequal(nn,0),
   nn = zeros(size(qn,1),size(rn,1));
end

% Extract plant data 
[a,bb,c,dd,ee] = dssdata(sys);
Ts = sys.Ts;
Nx = size(a,1);
[pd,md] = size(dd);

% Eliminate outputs that are not sensors
if ni<5,
   sensors = 1:pd;
elseif any(sensors<=0) | any(sensors>pd),
   error('Index in SENSORS out of range.')
end
c = c(sensors,:);
dd = dd(sensors,:);
Ny = size(c,1);
if Ny==0,
   error('Number of measurements y must be positive.')
end

% Check symmetry and dimensions of Qn,Rn,Nn
[Nw,Nw2] = size(qn);
Nu = md-Nw;
if Nw~=Nw2 | Nw>md,
   error('Qn must be square with fewer columns than inputs in SYS.')
elseif any(size(rn)~=Ny),
   error('Rn must be square with as many rows as measured outputs.')
elseif ~isequal(size(nn),[Nw Ny]),
   error('Nn must have as many rows as Qn and as many columns as Rn.')
elseif norm(qn'-qn,1) > 100*eps*norm(qn,1),
   warning('Qn is not symmetric and has been replaced by (Q+Q'')/2).')
elseif norm(rn'-rn,1) > 100*eps*norm(rn,1),
   warning('Rn is not symmetric and has been replaced by (R+R'')/2).')
end

% Extract B,G,D,H
if ni<6,
   % Stochastic inputs w are the last Nw=SIZE(Qn,2) inputs
   % and known inputs u are the remaining ones.
   known = 1:Nu;
elseif any(known<=0) | any(known>md),
   error('Index in KNOWN out of range.')
elseif length(known)~=Nu,
   error('Length of KNOWN and size of Qn should add up to the number of inputs in SYS.')
end
stoch = 1:md;
stoch(known) = [];
b = bb(:,known);   d = dd(:,known);
g = bb(:,stoch);   h = dd(:,stoch);


% Derive reduced matrices
%
%  [Qb  Nb]     [ G  0 ] [ Qn  Nn ] [ G  0 ]'
%  [      ]  =  [      ] [        ] [      ]
%  [Nb' Rb]     [ H  I ] [ Nn  Rn ] [ H  I ]
%
% First derive equivalent covariance matrices for the auxiliary 
% measurement noise vt := Hw+v
hn = h * nn;
nb = qn * h' + nn;
rb = rn  + hn + hn' + h * qn * h';
% Then incorporate G
qb = g * qn * g';
nb = g * nb;

% Enforce symmetry and check positivity
qb = (qb+qb')/2;
rb = (rb+rb')/2;
vr = real(eig(rb));
vqnr = real(eig([qb nb;nb' rb]));
if min(vr)<=0,
   error(sprintf(...
     ['The covariance matrix\n' ...
      '    E{(Hw+v)(Hw+v)''} = [H,I]*[Qn Nn;Nn'' Rn]*[H'';I]\n'...
      'must be positive definite.']))
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
   warning(...
     'The matrix [G 0;H I]*[Qn Nn;Nn'' Rn]*[G 0;H I]'' should be positive semi-definite.')
end


% Solve Riccati equation
if Nx==0,
   p = [];
   k = zeros(Ny,0);
   report = 0;
elseif Ts==0,
   % Call CARE for continuous case
   [p,e,k,report] = care(a',c',qb,rb,nb,ee','report');
   str = ' jw axis ';
else
   % Call DARE for discrete case
   [p,e,k,report] = dare(a',c',qb,rb,nb,ee','report');
   str = ' unit circle ';
end

% Handle failure
if report==-1,
   error(sprintf(...
      ['(C,A) or (A,G*Q*G'') has non minimal modes near' str ...
         '(assuming N=0\nand H=0, see Control System Toolbox ' ...
         'User''s Guide for general case).']))
elseif report==-2,
   error('(C,A) is undetectable.')
end


% Build Kalman estimator (Ae,Be,Ce,De)
l = k';
ae = a-l*c;
be = [b-l*d , l];
if Ts==0,
   % Continuous state-space estimator
   %      .                             |u|
   %     x_e  = [A-LC] x_e + [B-LD , L] |y|
   %                                    
   %    |y_e| = [C] x_e + [D 0] |u|
   %    |x_e| = [I]       [0 0] |y|
   m = [];
   z = [];
   ce = [c ; eye(Nx)];
   de = [d zeros(Ny);zeros(Nx,Nu+Ny)];

else
   % Discrete state-space estimator:
   %                                             |u[n]|
   %    x[n+1|n] = [A-LC] x[n|n-1] + [B-LD , L]  |y[n]|
   %    
   %    |y[n|n]| = [(I-CM)C] x[n|n-1] + [(I-CM)D  CM]  |u[n]|
   %    |x[n|n]| = [ I-MC  ]            [ -MD      M]  |y[n]|
   % with
   %                           -1                       -1
   %    L = (APC'+Nb) (CPC'+Rb) ,      M = PC' (CPC'+Rb) 
   %    
   % where P = solution of DARE,   Z = (I-MC)*P
   %
   m = p*c'/(rb+c*p*c');  % Nx-by-Ny
   imc = eye(Nx)-m*c;
   icm = eye(Ny)-c*m;
   z = imc*p;
   z = (z+z')/2;
   ce = [icm*c ; imc];
   de = [icm*d c*m;-m*d m];

end


% Get names for u, y, x
Uname = sys.InputName(known);
Yname = sys.OutputName(sensors);
Sname = get(sys,'statename');

% Use default name uj if all model inputs are unnamed
if all(strcmp(sys.InputName,'')),
   for i=1:Nu,  Uname{i} = sprintf('u%d',known(i));  end
end

% Use default name yj if all model outputs are unnamed
if all(strcmp(sys.OutputName,'')),
   for i=1:Ny,  Yname{i} = sprintf('y%d',sensors(i));  end
end

% Gives names to estimated states and outputs by 
% appending _e to state and measurement names
XeNames = cell(Nx,1);
if all(strcmp(Sname,'')),
   for i=1:Nx,  XeNames{i} = sprintf('x%d_e',i);  end
else
   for i=1:Nx,  XeNames{i} = [Sname{i} '_e'];  end
end     
YeNames = cell(Ny,1);
for i=1:Ny,  YeNames{i} = [Yname{i} '_e'];  end

% Set input groups to 'KnownInput' and 'Measurement'
InputGroup = cell(0,2);
if Nu,  InputGroup = [InputGroup ; {1:Nu 'KnownInput'}];  end
if Ny,  InputGroup = [InputGroup ; {Nu+1:Nu+Ny 'Measurement'}];  end

% Set output groups to 'OutputEstimate' and 'StateEstimate'
OutputGroup = cell(0,2);
if Ny,  OutputGroup = [OutputGroup ; {1:Ny 'OutputEstimate'}];  end
if Nx,  OutputGroup = [OutputGroup ; {Ny+1:Ny+Nx 'StateEstimate'}]; end

% Form LTI system KEST
kest = dss(ae,be,ce,de,ee,Ts,'statename',XeNames);
kest.InputName = [Uname ; Yname];
kest.OutputName = [YeNames ; XeNames];
kest.InputGroup = InputGroup;
kest.OutputGroup = OutputGroup;

