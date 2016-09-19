function out = matching_eval( benchpath, labelspath, resultspath )
%MATCHING_EVAL Evaluate the matching task results
%  RES = MATCHING_EVAL(BENCHPATH, LABELSPATH, RESULTSPATH) Evaluates the
%  matching benchmark specified in BENCHPATH with labels stored in
%  LABELSPATH and results stored in RESULTSPATH.
%
%  Returns a structure array with values per image pair in mathcing task:
%    name              - Image pair specification
%    precision, recall - Points on the PR curve
%    ap                - Average precision
%    precision_2nnr, recall_2nnr
%                      - Points on the PR curve using the Lowe's 2NN ratio
%    ap_2nnr           - AP using the Lowe's 2NN ratio.
%
%  See also: matching_compute

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

fprintf(isdeployed+1, ...
  'Evaluating matching results:\n\tBENCHMARK=%s\n\tLABELS=%s\n\tRESFILE=%s\n', ...
  benchpath, labelspath, resultspath);

% Read the benchmark file
benchmarks = utls.readfile(benchpath);
% Read the labels file
labels = utls.readfile(labelspath);
assert(numel(labels) == numel(benchmarks)*3, 'Invalid labels file.');
% Read the results file
results = utls.readfile(resultspath);
assert(numel(results) == numel(benchmarks)*5, 'Invalid results file.');

out = cell(1, numel(benchmarks));
updt = utls.textprogressbar(numel(benchmarks));
for ti = 1:numel(benchmarks)
  % Load the task definition
  li = (ti-1)*3+1; ri = (ti-1)*5+1;
  assert(strcmp(benchmarks{ti}, labels{li}), 'Invalid labels file.');
  assert(strcmp(benchmarks{ti}, results{ri}), 'Invalid results file.');
  
  % Load the labels
  labelsB = utls.parsenumline(labels{li+1}, true) + 1;
  labelsA = 1:numel(labelsB);
  assert(numel(labelsA) == numel(labelsB), 'Invalid labels file.');
  numFeatures = max(labelsA);
  
  matchesB = utls.parsenumline(results{ri+1}, true) + 1;
  matchesA = 1:numel(matchesB);
  dists1t2 = utls.parsenumline(results{ri+2});
  dists1t3 = utls.parsenumline(results{ri+4});
  invalid = isnan(dists1t2) | isinf(dists1t2) | isnan(dists1t3) | isinf(dists1t3);
  dists1t2(invalid) = inf; dists1t3(invalid) = inf; 
  assert(all(dists1t2 <= dists1t3), 'Invalid results file - 1stNN further than 2ndNN.');
  distsRatio = dists1t3 ./ dists1t2;
  assert(numel(matchesA) == numel(labelsA), 'Invalid results file.');
  assert(numel(matchesB) == numel(labelsA), 'Invalid results file.');
  assert(numel(dists1t2) == numel(labelsA), 'Invalid results file.');
  assert(min(matchesA) > 0 && max(matchesA) <= numFeatures, 'Invalid results file');
  assert(min(matchesB) > 0 && max(matchesB) <= numFeatures, 'Invalid results file');
  
  % Convert the matched into a single value (index in the adjacency matrix)
  gtMatches = sub2ind([numel(labelsA), numel(labelsA)], labelsA, labelsB);
  matches = sub2ind([numel(matchesA), numel(matchesA)], matchesA, matchesB);
  
  % Compute the scores
  isValid = ismember(matches, gtMatches);
  [recall_1nn, precision_1nn, info_1nn] = vl_pr(isValid*2 - 1, -dists1t2);
  if isnan(info_1nn.ap), info_1nn.ap = 0; end
  [recall_2nn, precision_2nn, info_2nn] = vl_pr(isValid*2 - 1, distsRatio);
  if isnan(info_2nn.ap), info_2nn.ap = 0; end
  
  out{ti} = struct(...
    'recall', recall_1nn, 'precision', precision_1nn, 'ap', info_1nn.ap, ...
    'recall_2nnr', recall_2nn, 'precision_2nnr', precision_2nn, 'ap_2nnr', info_2nn.ap, ...
    'name', benchmarks{ti});
  updt(ti);
end
out = cell2mat(out);

end
