function out = matching_eval( benchpath, labelspath, resultspath )
assert(exist(benchpath, 'file') == 2, ...
  'Benchmark file %s does not exist.', benchpath);
assert(exist(labelspath, 'file') == 2, ...
  'Benchmark file %s does not exist.', labelspath);
assert(exist(resultspath, 'file') == 2, ...
  'Benchmark file %s does not exist.', resultspath);

% Read the benchmark file
tasks = utls.readfile(benchpath);

% Read the labels file
labels = utls.readfile(labelspath);
assert(numel(labels) == numel(tasks)*3);

% Read the results file
results = utls.readfile(resultspath);
assert(numel(results) == numel(tasks)*4);

out = cell(1, numel(tasks));
updt = utls.textprogressbar(numel(tasks));
for ti = 1:numel(tasks)
  % Load the task definition
  li = (ti-1)*3+1; ri = (ti-1)*4+1;
  assert(strcmp(tasks{ti}, labels{li}), 'Invalid labels file.');
  assert(strcmp(tasks{ti}, results{ri}), 'Invalid results file.');
  
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
  
  out{ti} = struct('recall', recall, 'precision', precision, 'ap', info.ap);
  updt(ti);
end
out = cell2mat(out);

end
