function boo = issiso(sys)
%ISSISO  True for SISO LTI models.
%
%   ISSISO(SYS) returns 1 (true) if SYS is a single-input,
%   single-output (SISO) model or array of models, and
%   0 (false) otherwise.
%
%   See also SIZE, ISEMPTY.

%   Author(s): A. Potvin, 3-1-94
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.5 $

sizes = size(sys);
boo = all(sizes(1:2)==1);

