function all(varargin)
%ALL Run all benchamrks
%  ALL DESCNAME Run all bencmarks for the descriptor DESCNAME
%  Additional arguments are passed to the descriptor and to all tasks.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

[des, varargin] = desc.memdesc(varargin{:});
bench.verification(des, varargin{:});
bench.matching(des, varargin{:});
bench.retrieval(des, varargin{:});
end