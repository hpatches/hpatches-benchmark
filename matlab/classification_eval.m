function res = classification_eval( benchpath, labelspath, resultspath, varargin )
%CLASSIFICATION_EVAL Evaluate the auc and map for classification results
%  RES = CLASSIFICATION_EVAL(BENCHPATH, LABELSPATH, RESULTSPATH)
%  computes AUC and AP for the classification task using the computed
%  distances from RESULTS_FILE.
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
opts.plot = [];
opts = vl_argparse(opts, varargin);

fprintf(isdeployed+1,'Evaluating classif results:\n\tRESPATH=%s\n', ...
  resultspath);

% Read the benchmark file
[dists, labels] = readres(resultspath);
if opts.balanced
  is_pos = find(labels == 1); is_neg = find(labels == 0, numel(is_pos));
  dists = dists([is_pos, is_neg]); labels = labels([is_pos, is_neg]);
end
labels = labels * 2 - 1;

[tpr, tnr, info_roc] = vl_roc(labels, -dists);
[recall, precision, info_pr] = vl_pr(labels, -dists);

res = struct(...
  'precision', precision, 'recall', recall, 'ap', info_pr.ap,  ...
  'tpr', tpr, 'tnr', tnr, 'auc', info_roc.auc, ...
  'numpos', sum(labels==1), 'numneg', sum(labels==-1));

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

function [dists, labels] = readres(path)
res = dlmread(path, ',');
assert(size(res, 2) == 2, 'Invalid results file.');
dists = res(:, 1)'; labels = res(:, 2)';
assert(all(labels ==0 | labels == 1), 'Invalid labels.');
end


