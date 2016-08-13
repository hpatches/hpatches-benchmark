function res = classification_eval( pos_res_path, neg_res_path, varargin )
opts.balanced = false;
opts = vl_argparse(opts, varargin);

% Read the benchmark file
pos_dists = readres(pos_res_path, 1);
neg_dists = readres(neg_res_path, 0);

if opts.balanced, neg_dists = neg_dists(1:numel(pos_dists)); end

labels = [ones(1, numel(pos_dists)), -ones(1, numel(neg_dists))];
scores = [-pos_dists, -neg_dists];

[tpr, tnr, info_roc] = vl_roc(labels, scores);
[recall, precision, info_pr] = vl_pr(labels, scores);

res = struct(...
  'precision', precision, 'recall', recall, 'ap', info_pr.ap,  ...
  'tpr', tpr, 'tnr', tnr, 'auc', info_roc.auc, ...
  'numpos', numel(pos_dists), 'numneg', numel(neg_dists));

if isdeployed
  fprintf('%s\tpatch_classif_auc\t%.2f\tpatch_classif_ap\n', ...
    opts.cacheName, res.auc, res.ap);
end

end

function dists = readres(path, label)
res = dlmread(path, ',');
assert(size(res, 2) == 2, 'Invalid results file.');
assert(all(res(:, 2) == label), 'Invalid results file.');
dists = res(:, 1)';
end
