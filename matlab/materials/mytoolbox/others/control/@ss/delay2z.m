function sys = delay2z(sys)
%DELAY2Z  Replace delays by poles at z=0 or FRD phase shift.  
%
%   For discrete-time TF, ZPK, or SS models SYS,
%      SYS = DELAY2Z(SYS) 
%   maps all time delays to poles at z=0.  Specifically, a 
%   delay of k sampling periods is replaced by (1/z)^k.
%
%   For FRD models, DELAY2Z absorbs all time delays into the 
%   frequency response data, and is applicable to both 
%   continuous- and discrete-time FRDs.
%
%   See also HASDELAY, PADE, LTIMODELS.

%	 P. Gahinet 8-28-96
%	 Copyright (c) 1986-98 by The MathWorks, Inc.
%	 $Revision: 1.2 $  $Date: 1998/05/18 22:41:43 $

error(nargchk(1,1,nargin));
if getst(sys.lti)==0,
   error('LTI model SYS must be discrete.')
elseif ~hasdelay(sys),
   return
end

% Data and dimensions
a = sys.a;
b = sys.b;
c = sys.c;
d = sys.d;
e = sys.e;
Ts = getst(sys.lti);
sizes = size(d);
ny = sizes(1);
nu = sizes(2);
nsys = prod(sizes(3:end));
Nx = nxarray(sys);
Ne = size(e,1);

% Extract delay info
DelayData = get(sys.lti,{'inputdelay','outputdelay','iodelaymatrix'});
[Tdin,Tdout,Tdio] = deal(DelayData{:});

% Recursively map the I/O delays to poles at zero
for k=1:nsys,
   nx = Nx(k);
   ne = min(nx,Ne);
   tdio = Tdio(:,:,min(k,end));
   
   if ~any(tdio(:)),
      % No I/O delay: map input and output delays to poles
      % at z=0 while preserving the original state (i.e.,
      % not shifting x[k] to x[k-T] by absorbing input delays
      % into output delays or vice versa)
      [ad,bd,cd,dd,ed,xnames] = ...
         delayios(a(1:nx,1:nx,k),b(1:nx,:,k),c(:,1:nx,k),d(:,:,k),e(1:ne,1:ne,k),...
                  Tdin(:,:,min(k,end)),Tdout(:,:,min(k,end)),sys.StateName);
   else
      % Absorb input and output delay in I/O delay matrix
      tdio = tdio + Tdin(:,ones(1,ny),min(k,end))' + ...
         Tdout(:,ones(1,nu),min(k,end));
      
      % Map I/O delays that can't be factored out as input or output
      % delays to poles at z=0
      [ad,bd,cd,dd,ed,id,od,xnames] = ...
         delay2pole(a(1:nx,1:nx,k),b(1:nx,:,k),c(:,1:nx,k),d(:,:,k),e(1:ne,1:ne,k),...
                    sys.StateName,tdio,tdpart(tdio));
      
      % Map remaining input and output delays to poles at z=0
      [id,od] = optdec(id,od);
      [ad,bd,cd,dd,ed,xnames] = delayios(ad,bd,cd,dd,ed,id,od,xnames);
   end
   
   nx = size(ad,1);   ne = size(ed,1);
   Nx(k) = nx;
   sys.a(1:nx,1:nx,k) = ad;
   sys.e(1:ne,1:ne,k) = ed;
   sys.b(1:nx,:,k) = bd;
   sys.c(:,1:nx,k) = cd;
   sys.d(:,:,k) = dd;      
end     

% Post-processing
sys.e = ematchk(sys.e,Nx);
sys.Nx = Nx;
sys.StateName = repmat({''},[size(sys.a,1) 1]);
sys = xclip(sys);
if length(sys.Nx)==1,
   % Uneven number of states
   sys.StateName = xnames;
end

% Set I/O delays to zero
sys.lti = set(sys.lti,'inputdelay',zeros(nu,1),...
                      'outputdelay',zeros(ny,1),...
                      'iodelaymatrix',zeros(ny,nu));



%%%%%% SUBFUNCTION DELAY2POLE

function [a,b,c,d,e,id,od,sn] = delay2pole(a,b,c,d,e,sn,Td,dpart)
%DELAY2POLE  Recursively maps I/O delays into poles at zero
%
%   Given a discrete model (A,B,C,D,E) with I/O delays TD, 
%   DELAY2POLE computes an equivalent model with only input 
%   delays ID and output delays OD.  All other delays are 
%   mapped to poles at z=0.

% Quick exit
if isempty(dpart),
   % Reached a terminal node (subsystem with DxDyTd=0)
   % Extract input and output delays
   [ny,nu] = size(Td);
   id = min(Td,[],1)';
   od = Td(:,1) - id(ones(1,ny),1);
   return
end

% Using the partition DPART of the I/O delay matrix, split
% (A,B,C,D,E) into two subsystems SYS1 and SYS2
r1 = 1:dpart{1}(1);   
r2 = r1(end)+1:r1(end)+dpart{1}(2);
dim = 1+(size(dpart,1)==1);

if dim==1,
   % Vertical concatenation
   [a1,b1,c1,e1,sn1] = smreal(a,b,c(r1,:),e,sn);   
   d1 = d(r1,:);  Td1 = Td(r1,:);
   [a2,b2,c2,e2,sn2] = smreal(a,b,c(r2,:),e,sn);   
   d2 = d(r2,:);  Td2 = Td(r2,:);
   concat = 'vcat';
else
   % Horizontal concatenation
   [a1,b1,c1,e1,sn1] = smreal(a,b(:,r1),c,e,sn);   
   d1 = d(:,r1);  Td1 = Td(:,r1);
   [a2,b2,c2,e2,sn2] = smreal(a,b(:,r2),c,e,sn);   
   d2 = d(:,r2);  Td2 = Td(:,r2);
   concat = 'hcat';
end

% By recursively applying DEL2POL to the subsystem SYS1 and SYS2, 
% derive equivalent models with only input and output delays for 
% SYS1 and SYS2
[a1,b1,c1,d1,e1,id1,od1,sn1] = delay2pole(a1,b1,c1,d1,e1,sn1,Td1,dpart{2});
[a2,b2,c2,d2,e2,id2,od2,sn2] = delay2pole(a2,b2,c2,d2,e2,sn2,Td2,dpart{3});

% Factor out input and output delays shared by SYS1 and SYS2, and map
% remaining delays to poles at z=0
if dim==1,
   [id,od,id1,od1,id2,od2] = ciod(id1,od1,id2,od2);
else
   [od,id,od1,id1,od2,id2] = ciod(od1,id1,od2,id2);
end
[id1,od1] = optdec(id1,od1);
[a1,b1,c1,d1,e1,sn1] = delayios(a1,b1,c1,d1,e1,id1,od1,sn1);
[id2,od2] = optdec(id2,od2);
[a2,b2,c2,d2,e2,sn2] = delayios(a2,b2,c2,d2,e2,id2,od2,sn2);

% Derive state-space matrices for CAT(DIM,SYS1,SYS2)
[e1,e2] = ematchk(e1,size(a1,1),e2,size(a2,1));
[a,b,c,d,e] = ssops(concat,a1,b1,c1,d1,e1,[],a2,b2,c2,d2,e2,[]);
sn = [sn1 ; sn2];   


%%%%% SUBFUNCTION CIOD

function [cid,cod,id1,od1,id2,od2] = ciod(id1,od1,id2,od2)
%CIOD  Factor out input and output delays in concatenation
%
%   CIOD factors out input delays CID and output delays COD
%   for SYS = [SYS1;SYS2] where SYS1 and SYS2 are two models
%   with input and output delays ID1,OD1 and ID2,OD2.  The
%   input and output delays CID and COD are chosen to minimize
%   the residual delay attached to SYS1 and SYS2.

p1 = length(od1);
p2 = length(od2);
m = length(id1);

% Allocation
cid = zeros(m,1);
cod = zeros(p1+p2,1);

% Dimension parameters
q = fix((m*p1)/(p1+p2));
delta = (m*p1)/(p1+p2) - q;
jswitch = q+(delta>0);

% Solve the LP 
%   max sum(cid)/m + sum(cod)/(p1+p2)  subject to
%       cod(i) + cid(j) <= od1(i) + id1(j) for i<=p1
%       cod(i) + cid(j) <= od2(i) + id2(j) for i>p1
%       cod>=0, cid>=0       
% Compute characteristic quantities
[Delta,jperm] = sort(id1-id2);
a = od1;
b = id1(jperm);
c = od2;
d = id2(jperm);
[bm,jx] = min(b);
[dm,jy] = min(d);
r = max(find(Delta<=bm));
s = min(find(Delta>=-dm));

% Construct optimal dual solution x,y
x = zeros(m,1);
y = zeros(m,1);
if jswitch>r,
   x(1:r) = 1;
   y(r+1:m) = 1;
   x(jx) = 1 + (q + delta) - r;
elseif jswitch<s,
   x(1:s-1) = 1;
   y(s:m) = 1;
   y(jy) = s - (q + delta);
else
   x(1:jswitch-1) = 1;
   y(jswitch+1:m) = 1;
   x(jswitch) = delta;
   y(jswitch) = 1-delta;
end

% Determine adequate value for parameters (theta,mu).
% Constraints are:
%    -min(a)<=theta,  -min(c)<=mu,   mu+m1 <= theta <= mu+m2
m1 = max(Delta(x>0));
m2 = min(Delta(y>0));
theta = -min(a);
mu = -min(c);
jd = find(x+y>1+1e3*eps);
if ~isempty(jd),
   if x(jd),
      theta = b(jd);   mu = max(mu,theta-m2);
   else
      mu = d(jd);      theta = max(theta,mu+m1);
   end
else
   if theta<mu+m1,
      theta = mu+m1;
   elseif theta>mu+m2,
      mu = theta-m2;
   end
end

% Derive optimal primal solution. 
cid(jperm(x>0)) = b(x>0) - theta;
cid(jperm(y>0)) = d(y>0) - mu;
cod(1:p1) = a + theta;
cod(p1+1:p1+p2) = c + mu;

% Generate residual delays
id1 = id1 - cid - theta;
id2 = id2 - cid - mu;
od1 = zeros(p1,1);
od2 = zeros(p2,1);


%%%%%%%% SUBFUNCTION OPTDEC

function [id,od] = optdec(id,od)
%OPTDEC  Optimal balancing of input and output delays
% 
%   The decomposition ID/OD is equivalent to ID+s/OD-s, but 
%   number of delay blocks added by DELAYIOS is not invariant 
%   under this transformation.
%
%   To minimize number of additional poles at z=0, OPTDEC 
%   maximizes ID if nu<=ny, and maximizes OD otherwise.

nu = length(id);
ny = length(od);

if nu<=ny,
   shift = min(od);
else
   shift = -min(id);
end

id = id + shift;
od = od - shift;
