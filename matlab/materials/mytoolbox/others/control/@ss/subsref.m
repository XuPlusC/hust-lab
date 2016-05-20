function result = subsref(sys,Struct)
%SUBSREF  Subscripted reference for LTI objects.
%
%   The following reference operations can be applied to any 
%   LTI model SYS: 
%      SYS(Outputs,Inputs)   select subset of I/O channels
%      SYS.Fieldname         equivalent to GET(SYS,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%   For LTI arrays, indexed referencing takes the form
%      SYS(Outputs,Inputs,j1,...,jk)
%   where k is the number of array dimensions (in addition
%   to the generic input and output dimensions).  Use 
%      SYS(:,:,j1,...,jk)
%   to access the (j1,...,jk) model in the LTI array.
%
%   See also GET, TFDATA, SUBSASGN, LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1998/08/24 19:17:26 $

% Effect on LTI properties: all inherited

ni = nargin;
if ni==1,
   result = sys;
   return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
case '.'
   % The first subreference is of the form sys.fieldname
   % The output is a piece of one of the system properties
   try
      if StructL==1,
         result = get(sys,Struct(1).subs);
      else
         result = subsref(get(sys,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
case '()'
   % The first subreference is of the form sys(indices)
   try
      if StructL==1,
         result = indexref(sys,Struct(1).subs);
      else
         result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
case '{}'
   error('Cell contents reference from a non-cell array object')
otherwise
   error(['Unknown reference type: ' Struct(1).type])
end



% Subfunction INDEXREF: Evaluates sys(indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,indices)

sizes = size(sys.d);

% Check indices
nind = length(indices);
if nind==1,
   if length(sizes)>2 | min(sizes)>1,
      error('Use multiple indexing for MIMO models or LTI arrays, as in SYS(i,j).');
   elseif sizes(1)==1,  % 2D, single output
      indices = [{':'} indices];
   else                 % 2D, single input
      indices = [indices {':'}];
   end
elseif length(sizes)==2 & isequal(indices,{':' ':' 1}),
   % Quick exit for SYS(:,:,1) to optimize multi-model loops in single-model case
   return
end

% Check and format indices
indices = refchk(indices,sizes,sys.lti);

% Extract desired subsystem
sys.a = sys.a(:,:,indices{3:end});
sys.b = sys.b(:,indices{2:end});
sys.c = sys.c(indices{1},:,indices{3:end});
sys.d = sys.d(indices{:});
sys.e = sys.e(:,:,indices{3:end});
sys.lti = sys.lti(indices{:});

% Adjust state dimensions and discard extra zero pads
if length(sys.Nx)>1 & length(indices)>2,
   sys.Nx = sys.Nx(indices{3:end});
   sys = xclip(sys);
end

% Compactify E if non descriptor
sys.e = ematchk(sys.e,sys.Nx);

% Note: don't systematically reduce the subsystem with MINSTRUCT
%       (this messes up applications like LQG design where gain and 
%       estimators need to be designed with same number of states, cf
%       MILLDEMO)




