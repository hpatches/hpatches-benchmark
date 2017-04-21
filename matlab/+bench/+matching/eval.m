function res = eval( descA, descB, varargin )

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.matcher = 'vlfeat';
[opts, ~] = vl_argparse(opts, varargin);

% Compute the descriptors
assert(size(descA, 2) == size(descB, 2));
switch opts.matcher
  case 'vlfeat'
    tr = vl_kdtreebuild(descB);
    [idx, dist] = vl_kdtreequery(tr, descB, descA, 'NumNeighbors', 2);
  case 'matlab'
    tr = KDTreeSearcher(descB');
    [idx, dist] = knnsearch(tr, descA', 'K', 2);
    idx = idx'; dist = dist';
end
dist(isnan(dist)) = inf;
isValid = idx(1,:) == 1:size(idx, 2);

% Compute the scores
[rec1nn, pr1nn, i1nn] = vl_pr(isValid*2 - 1, -dist(1,:), 'numPositives', numel(isValid));
if isnan(i1nn.ap), i1nn.ap = 0; end
[rec2nn, pr2nn, i2nn] = vl_pr(isValid*2 - 1, dist(2,:) ./ dist(1,:), 'numPositives', numel(isValid));
if isnan(i2nn.ap), i2nn.ap = 0; end

res = struct('ap', i1nn.ap, 'auc', i1nn.auc, 'ap_2nnr', i2nn.ap, ...
  'sr', sum(isValid)/numel(isValid), 'pr', [pr1nn; rec1nn], ...
  'pr_2nn', [pr2nn; rec2nn]);

end
