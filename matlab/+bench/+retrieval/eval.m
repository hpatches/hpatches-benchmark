function res = eval( descs, geom_noise, queryfile, distfile, varargin )

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.debug = false;
opts.queryims = 1;
opts.pos_ims = [2,3,4,5,6]; % Removequery by default
opts.neg_ims = 1;
opts.num_neg = 2000;
opts.topn = inf;
opts.numqueries = inf;
opts.testap = false;
opts.numtype = 'single';
[opts, varargin] = vl_argparse(opts, varargin);

queries = readtable(queryfile);
queries = queries(1:min(opts.numqueries, size(queries, 1)), :);
queries_num = size(queries, 1);
neg = readtable(distfile); neg_num = size(neg, 1);
[query_desc, query_si] = descs.getdesc(descs, queries.s, geom_noise, ...
  ones(1, queries_num), queries.idx + 1);
pos_desc = getimsdesc(descs, queries.s, geom_noise, opts.pos_ims, queries.idx);
% neg_si - sequence idx
[neg_desc, neg_si] = descs.getdesc(descs, neg.s, geom_noise, ...
  opts.neg_ims * ones(1, neg_num), neg.idx + 1);
% Subsample the negs
neg_sel = 1:min(size(neg_desc, 2), opts.num_neg);
neg_desc = neg_desc(:, neg_sel);
neg_si = neg_si(:, neg_sel);

% Query the positives
pos_dists = squeeze(sum(bsxfun(@minus, pos_desc, query_desc).^2, 1))';
% Query the neg
t = vl_kdtreebuild(neg_desc);
[neg_idxs, neg_dists] = vl_kdtreequery(t, neg_desc, query_desc, ...
  'numneighbors', min(opts.topn, size(neg_desc, 2)), varargin{:});
neg_si = single(neg_si(neg_idxs));

neg_labels = -ones(size(neg_dists), opts.numtype);
ignored = bsxfun(@eq, neg_si, single(query_si));
neg_labels(ignored) = 0;
clear ignored;

all_labels = [ones(size(pos_dists), opts.numtype); neg_labels];
all_scores = [single(-pos_dists); -neg_dists];
clear neg_dists neg_labels;
if opts.debug
  all_idxs = [repmat((1:numel(opts.pos_ims))', 1, size(pos_dists, 2)); ...
    double(neg_idxs)];
  all_si = [repmat(query_si, numel(opts.pos_ims), 1); neg_si];
else
  clear neg_si neg_idxs;
end

[all_scores, idxs] = sort(all_scores, 1, 'descend');
idxs = bsxfun(@plus, idxs, cast((0:(size(idxs, 2)-1))*size(idxs, 1), ...
  opts.numtype));
all_labels = all_labels(idxs);
if opts.debug
  all_idxs = all_idxs(idxs);
  all_si = all_si(idxs);
else
  clear all_scores idxs;
end

tp = [zeros(1, queries_num); cumsum(all_labels > 0, 1)] ;
fp = [zeros(1, queries_num); cumsum(all_labels < 0, 1)] ;
small = 1e-10 ; p = numel(opts.pos_ims);
recall = tp ./ max(p, small) ;
precision = max(tp, small) ./ max(tp + fp, small) ;

auc = 0.5 * sum((precision(1:end-1,:) + precision(2:end,:)) .* diff(recall), 1) ;
sel = diff(recall) ~= 0 ; sel = [false(1, queries_num); sel];
ap = precision; ap(~sel) = 0;
ap = sum(ap, 1) ./ p ;
res = struct('ap', ap, 'auc', auc, 'map', mean(ap));

if opts.testap
  % Test whether the in-place ap computation gives the same results as
  % vl_pr implementation
  for qi = 1:size(all_scores, 2)
    [~, ~, info] = vl_pr(all_labels(:, qi), all_scores(:, qi));
    assert(info.ap == ap(qi));
    assert(info.auc == auc(qi));
  end
end

end

function d = getimsdesc(descs, seq, geom_noise, ims, idxs)
d = arrayfun(@(im) descs.getdesc(descs, seq, geom_noise, ...
  im*ones(1, numel(idxs)), idxs + 1), ims, 'uni', false);
d = cat(3, d{:});
end
