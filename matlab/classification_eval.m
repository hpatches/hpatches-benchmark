function res = classification_eval( pos_res_path, neg_res_path, varargin )
%CLASSIFICATION_EVAL Evaluate the auc and map for classification results
%  RES = CLASSIFICATION_EVAL(POS_RES_FILE, NEG_RES_FILE) computes AUC and AP
%  for the classification task using the computed distances from
%  POS_RES_FILE and NEG_RES_FILE.
%
%  Returns a structure with fields:
%    precision, recall - Points on the PR curve
%    ap                - Average precision
%    tpr, tnr          - True positive rate and true negative rate for ROC
%    auc               - Area under the ROC curve
%    numpos            - Number of positives
%    numneg            - Number of negatives
%
%  Additionally accepts the following arguments:
%
%  balanced :: false
%    When true, use same number of negatives and positive samples. Top-N
%    negatives are picked.
%
%  plot :: false
%    Plot the ROC and PR curve.
%
%  See also: classification_compute

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.balanced = false;
opts.plot = false;
opts = vl_argparse(opts, varargin);

fprintf(isdeployed+1,'Evaluating classif results:\n\tPAIRS_POS=%s\n\tPAIRS_NEG=%s\n', ...
  pos_res_path, neg_res_path);

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

if ~isempty(opts.plot)
  figure(1); clf; subplot(1,2,1);
  plot([0, 1], [0, 1], 'r--', 'LineWidth', 1); hold on;
  plot(1 - res.tnr, res.tpr, 'LineWidth', 2, 'Color', 'g');
  legend({'Chance', 'Result'}, 'Location', 'SouthEast');
  xlabel('False positive rate'); ylabel('True positive rate');
  grid on; title('ROC');
  
  %% Plot the PR curves
  subplot(1,2,2);
  pos_neg_ratio = res.numpos ./ (res.numneg + res.numpos);
  plot([0, 1], [pos_neg_ratio, pos_neg_ratio], 'r--', 'LineWidth', 1); hold on;
  plot(res.recall, res.precision, 'LineWidth', 2, 'Color', 'g');
  legend({'Chance', 'Result'}, 'Location', 'SouthEast');
  xlabel('Recall'); ylabel('Precision');
  grid on; title('PR');
end

end

function dists = readres(path, label)
res = dlmread(path, ',');
assert(size(res, 2) == 2, 'Invalid results file.');
assert(all(res(:, 2) == label), 'Invalid results file.');
dists = res(:, 1)';
end


