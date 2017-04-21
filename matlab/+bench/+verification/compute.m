function dists = compute( pairspath, descs, geom_noise, varargin )

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.metric = 'L2';
[opts, ~] = vl_argparse(opts, varargin);

pairs = readtable(pairspath);

descsA = descs.getdesc(descs, pairs.s1, geom_noise, pairs.t1 + 1, pairs.idx1 + 1);
descsB = descs.getdesc(descs, pairs.s2, geom_noise, pairs.t2 + 1, pairs.idx2 + 1);

switch opts.metric
  case 'L1'
    dists = sum(abs(descA - descB), 1);
  case 'L2'
    dists = sum((descsA - descsB).^2, 1);
  otherwise
    error('Invalid metric.');
end

end