function out = matching_eval( benchpath, labelspath, resultspath )
% Read the benchmark file
benchmarks = utls.readfile(benchpath);
% Read the labels file
labels = utls.readfile(labelspath);
assert(numel(labels) == numel(benchmarks)*3, 'Invalid labels file.');
% Read the results file
results = utls.readfile(resultspath);
assert(numel(results) == numel(benchmarks)*4, 'Invalid results file.');

out = cell(1, numel(benchmarks));
updt = utls.textprogressbar(numel(benchmarks));
for ti = 1:numel(benchmarks)
  % Load the task definition
  li = (ti-1)*3+1; ri = (ti-1)*4+1;
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
  [recall, precision, info] = vl_pr(isValid*2 - 1, -dists);
  if isnan(info.ap), info.ap = 0; end
  
  out{ti} = struct('recall', recall, 'precision', precision, 'ap', info.ap, ...
    'name', benchmarks{ti});
  updt(ti);
end
out = cell2mat(out);

end
