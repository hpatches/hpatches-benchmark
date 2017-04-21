function res = eval( pos_dists, neg_dists, varargin )
%VERIFICATION_EVAL Evaluate the auc and map for verification results
%
%  See also: verification_compute

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.posneg_ratio = [];
[opts, ~] = vl_argparse(opts, varargin);

% Read the benchmark file
pos_dists = reshape(pos_dists, 1, []);
neg_dists = reshape(neg_dists, 1, []);
if ~isempty(opts.posneg_ratio)
  pos_dists = pos_dists(1:floor(numel(neg_dists)*opts.posneg_ratio));
end

labels = [ones(1, numel(pos_dists)), -ones(1, numel(neg_dists))];
dists = [pos_dists, neg_dists];
[tpr, tnr, info_roc] = vl_roc(labels, -dists);
[recall, precision, info_pr] = vl_pr(labels, -dists);

res = struct(...
  'precision', precision, 'recall', recall, ...
  'pr_ap', info_pr.ap, 'pr_auc', info_pr.auc, ...
  'tpr', tpr, 'tnr', tnr, 'roc_auc', info_roc.auc, ...
  'numpos', sum(labels==1), 'numneg', sum(labels==-1));

end

