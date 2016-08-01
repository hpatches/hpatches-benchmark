function out = matching_eval( benchpath, labelspath, resultspath )
assert(exist(benchpath, 'file') == 2, ...
  'Benchmark file %s does not exist.', benchpath);
assert(exist(labelspath, 'file') == 2, ...
  'Benchmark file %s does not exist.', labelspath);
assert(exist(resultspath, 'file') == 2, ...
  'Benchmark file %s does not exist.', resultspath);

% Read the benchmark file
assert(exist(benchpath, 'file') == 2, ...
  'File %s does not exist.', benchpath);
fd = fopen(benchpath, 'r');
tasks = textscan(fd, '%s', 'delimiter', '\n'); tasks = tasks{1};
fclose(fd);

% Read the labels file
assert(exist(labelspath, 'file') == 2, ...
  'File %s does not exist.', labelspath);
fd = fopen(labelspath, 'r');
labels = textscan(fd, '%s', 'delimiter', '\n'); labels = labels{1};
fclose(fd);
assert(numel(labels) == numel(tasks)*3);

% Read the results file
assert(exist(resultspath, 'file') == 2, ...
  'File %s does not exist.', resultspath);
fd = fopen(resultspath, 'r');
results = textscan(fd, '%s', 'delimiter', '\n'); results = results{1};
fclose(fd);
assert(numel(results) == numel(tasks)*4);

out = cell(1, numel(tasks));
updt = utls.textprogressbar(numel(tasks));
for ti = 1:numel(tasks)
  li = (ti-1)*3+1; ri = (ti-1)*4+1;
  assert(strcmp(tasks{ti}, labels{li}), 'Invalid labels file.');
  assert(strcmp(tasks{ti}, results{ri}), 'Invalid results file.');
  
  labelsA = parseline(labels{li+1}) + 1;
  labelsB = parseline(labels{li+2}) + 1;
  assert(numel(labelsA) == numel(labelsB), 'Invalid labels file.');
  gtMatches = sub2ind([numel(labelsA), numel(labelsA)], labelsA, labelsB);
  
  matchesA = parseline(results{ri+1}) + 1;
  matchesB = parseline(results{ri+2}) + 1;
  dists = parseline(results{ri+3});
  assert(numel(matchesA) == numel(labelsA), 'Invalid results file.');
  assert(numel(matchesB) == numel(labelsA), 'Invalid results file.');
  assert(numel(dists) == numel(labelsA), 'Invalid results file.');
  
  matches = sub2ind([numel(matchesA), numel(matchesA)], matchesA, matchesB);
  isValid = ismember(matches, gtMatches);
  [recall, precision, info] = vl_pr(isValid*2 - 1, -dists);
  if isnan(info.ap), info.ap = 0; end
  out{ti} = struct('recall', recall, 'precision', precision, 'ap', info.ap);
  updt(ti);
end
out = cell2mat(out);

end


function data = parseline(line)
data = strsplit(line, ',');
data = cellfun(@str2double, data);
assert(all(~isnan(data)), 'Invalid data...');
end
