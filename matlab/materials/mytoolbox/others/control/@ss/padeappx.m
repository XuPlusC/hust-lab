function sys = padeappx(sys,id,od,iod,Ni,No,Nio)
%PADEAPPX  Pade approximation algorithm.
%
%   SYSX = PADEAPPX(SYS,ID,OD,IOD,NI,NO,NIO).
%
%   LOW-LEVEL UTILITY.  See PADE.

%   Author: P. Gahinet 5-98
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 1998/05/18 22:39:32 $

sizes = size(sys.d);
ny = sizes(1);
nu = sizes(2);
Nx = nxarray(sys);
Ne = size(sys.e,1);
sn = sys.StateName;

% Loop over each model in SS array
for m=1:prod(sizes(3:end))
   na = Nx(m);
   ne = min(na,Ne);
   a = sys.a(1:na,1:na,m);
   b = sys.b(1:na,:,m);
   c = sys.c(:,1:na,m);
   d = sys.d(:,:,m);
   e = sys.e(1:ne,1:ne,m);

   % Approximate I/O delays
   tdio = iod(:,:,min(m,end));
   niod = Nio(:,:,min(m,end));
   nzr = any(tdio,2)';  % zero rows of tdio
   nzc = any(tdio,1);   % zero columns of tdio

   if ~any(tdio(:)),
      ax = a;  bx = b;  cx = c;  dx = d;  ex = e;  snx = sn;

   elseif sum(nzc)<=sum(nzr),
      % Column-wise Pade approximation of TDIO
      cperm = [find(~nzc) , find(nzc)];
      [ax,bx,cx,ex,snx] = smreal(a,b(:,~nzc),c,e,sn);
      dx = d(:,~nzc);

      % Approximate nonzero columns of TDIO
      for j=find(nzc),
         [aj,bj,cj,ej,snj] = smreal(a,b(:,j),c,e,sn);
         % Approximate j-th column of TDIO as output delays for SYS(:,j,m)
         [aj,bj,cj,dj,ej,snj] = ...
             delayappx(aj,bj,cj,d(:,j),ej,snj,[],[],tdio(:,j),niod(:,j));
         % Concatenate with other columns
         [ex,ej] = ematchk(ex,size(ax,1),ej,size(aj,1));
         [ax,bx,cx,dx,ex] = ssops('hcat',ax,bx,cx,dx,ex,[],aj,bj,cj,dj,ej,[]);
         snx = [snx ; snj];
      end

      % Undo column permutation
      bx(:,cperm) = bx;
      dx(:,cperm) = dx;

   else
      % Row-wise Pade approximation of TDIO
      rperm = [find(~nzr) , find(nzr)];
      [ax,bx,cx,ex,snx] = smreal(a,b,c(~nzr,:),e,sn);
      dx = d(~nzr,:);
  
      % Approximate nonzero rows of TDIO
      for i=find(nzr),
         [ai,bi,ci,ei,sni] = smreal(a,b,c(i,:),e,sn);
         % Approximate i-th row of TDIO as input delays for SYS(i,:,m)
         [ai,bi,ci,di,ei,sni] = ...
             delayappx(ai,bi,ci,d(i,:),ei,sni,tdio(i,:),niod(i,:),[],[]);
         % Concatenate with other rows
         [ex,ei] = ematchk(ex,size(ax,1),ei,size(ai,1));
         [ax,bx,cx,dx,ex] = ssops('vcat',ax,bx,cx,dx,ex,[],ai,bi,ci,di,ei,[]);
         snx = [snx ; sni];
      end

      % Undo row permutation
      cx(rperm,:) = cx;
      dx(rperm,:) = dx;
   end

   % Approximate input and output delays
   [ax,bx,cx,dx,ex,snx] = delayappx(ax,bx,cx,dx,ex,snx,...
            id(:,:,min(m,end)),Ni(:,:,min(m,end)),...
            od(:,:,min(m,end)),No(:,:,min(m,end)));

   % Store result
   nax = size(ax,1);    nex = size(ex,1);
   sys.a(1:nax,1:nax,m) = ax;
   sys.b(1:nax,:,m) = bx;
   sys.c(:,1:nax,m) = cx;
   sys.d(:,:,m) = dx;
   sys.e(1:nex,1:nex,m) = ex;
   Nx(m) = nax;
end

sys.e = ematchk(sys.e,Nx);
sys.Nx = Nx;
sys.StateName(1:size(sys.a,1)) = {''};
sys = xclip(sys);
if length(sys.Nx)==1,
   % Keep state names if state dimension is uniform
   sys.StateName = snx;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a,b,c,d,e,sn] = delayappx(a,b,c,d,e,sn,id,Ni,od,No)
%DELAYAPPX  Pade approximation of input and output delays
%           in single state-space model.

na = size(a,1);
ne = size(e,1);
descriptor = (ne>0);
[ny,nu] = size(d);

% Approximate input delays
for j=find(id(:)'),
   [aj,bj,cj,dj] = pade(id(j),Ni(j));
   % Filter j-th input by Pade appx of ID(j)
   a = [a b(:,j)*cj ; zeros(Ni(j),na) aj];
   b(1:na+Ni(j),j) = [dj*b(:,j) ; bj];
   c = [c , d(:,j)*cj];
   d(:,j) = dj * d(:,j);
   if descriptor,
      e = [e zeros(na,Ni(j)) ; zeros(Ni(j),na) eye(Ni(j))];
   end
   na = na + Ni(j);
end

% Approximate output delays
for i=find(od(:)'),
   [ai,bi,ci,di] = pade(od(i),No(i));
   % Filter i-th output by Pade appx of OD(i)
   a = [a zeros(na,No(i)) ; bi*c(i,:) ai];
   b = [b ; bi * d(i,:)];
   c(i,1:na+No(i)) = [di*c(i,:) , ci];
   d(i,:) = di * d(i,:);
   if descriptor,
      e = [e zeros(na,No(i)) ; zeros(No(i),na) eye(No(i))];
   end
   na = na + No(i);
end

sn(end+1:na,1) = {''};




