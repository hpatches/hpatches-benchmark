function out = matching_eval( benchpath, labelspath, resultspath )
% Read the benchmark file
benchmarks = utls.readfile(benchpath);
% Read the labels file
labels = utls.readfile(labelspath);
assert(numel(labels) == numel(benchmarks)*3, 'Invalid labels file.');
% Read the results file
results = utls.readfile(resultspath);
assert(numel(results) == numel(benchmarks)*6, 'Invalid results file.');

out = cell(1, numel(benchmarks));
updt = utls.textprogressbar(numel(benchmarks));
for ti = 1:numel(benchmarks)
  % Load the task definition
  li = (ti-1)*3+1; ri = (ti-1)*6+1;
  assert(strcmp(benchmarks{ti}, labels{li}), 'Invalid labels file.');
  assert(strcmp(benchmarks{ti}, results{ri}), 'Invalid results file.');
  
  % Load the labels
  labelsA = utls.parsenumline(labels{li+1}, true) + 1;
  labelsB = utls.parsenumline(labels{li+2}, true) + 1;
  assert(numel(labelsA) == numel(labelsB), 'Invalid labels file.');
  numFeatures = max(labelsA);
  
  matchesA = utls.parsenumline(results{ri+1}, true) + 1;
  matchesB = utls.parsenumline(results{ri+2}, true) + 1;
  dists = utls.parsenumline(results{ri+3});
  distsRatio = utls.parsenumline(results{ri+5}) ./ dists;
  assert(numel(matchesA) == numel(labelsA), 'Invalid results file.');
  assert(numel(matchesB) == numel(labelsA), 'Invalid results file.');
  assert(numel(dists) == numel(labelsA), 'Invalid results file.');
  assert(min(matchesA) > 0 && max(matchesA) <= numFeatures, 'Invalid results file');
  assert(min(matchesB) > 0 && max(matchesB) <= numFeatures, 'Invalid results file');
  
  % Convert the matched into a single value (index in the adjacency matrix)
  gtMatches = sub2ind([numel(labelsA), numel(labelsA)], labelsA, labelsB);
  matches = sub2ind([numel(matchesA), numel(matchesA)], matchesA, matchesB);
  
  % Compute the scores
  isValid = ismember(matches, gtMatches);
  [recall_1nn, precision_1nn, info_1nn] = vl_pr(isValid*2 - 1, -dists);
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
