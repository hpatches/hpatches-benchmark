function out = retrieval_eval( imdb, benchpath, labelspath, resultspath )
% Read the benchmark file
benchmarks = reshape(utls.readfile(benchpath), 3, []);
% Read the labels file
labels = utls.readfile(labelspath);
% Read the results file
results = utls.readfile(resultspath);

aps = cell(1, size(benchmarks, 2));
apsCh = cell(1, size(benchmarks, 2));
updt = utls.textprogressbar(size(benchmarks, 2));
li = 1; ri = 1;
for ti = 1:size(benchmarks, 2)
  % Check the task headers if they agree
  assert(strcmp(benchmarks{1, ti}, labels{li}), ...
    'Invalid labels file task header.');
  assert(strcmp(benchmarks{1, ti}, results{ri}), ...
    'Invalid results file task header.');
  
  poolSignsN = decodeSigns(imdb, benchmarks{2, ti});
  querySignsN = decodeSigns(imdb, benchmarks{3, ti});
  queryClusters = zeros(1, size(querySignsN, 2));
  
  % Load the labels - create clusters of images and map each query to one
  li = li+1; clusters = {}; clustrIdx = 1;
  while li <= numel(labels) && isempty(strfind(labels{li}, 'task_'))
    clusterImsN = decodeSigns(imdb, labels{li}); li = li + 1;
    clustrQueriesN = decodeSigns(imdb, labels{li}); li = li + 1;
    assert(all(ismember(clusterImsN', poolSignsN', 'rows')), ...
      'Invalid pool images in the labels file.');
    
    [qFound, qIdx] = ismember(clustrQueriesN', querySignsN', 'rows');
    assert(all(qFound), 'Label queries not found in the benchmark definition.');
    queryClusters(qIdx) = clustrIdx;
    clusters{clustrIdx} = clusterImsN;
    clustrIdx = clustrIdx + 1;
  end
  
  aps{ti} = zeros(size(querySignsN, 2), 1);
  apsCh{ti} = zeros(size(querySignsN, 2), 1);
  poolNPathces = sum(imdb.sequences.npatches(poolSignsN(1, :)));
  clustersNPatches = cellfun(@(c) sum(imdb.sequences.npatches(c(1,:))), clusters);

  ri = ri + 1;
  for qi = 1:size(querySignsN, 2)
    assert(ri <= numel(results), 'Results file does not contain all records.');
    solN = decodeSigns(imdb, results{ri});
    assert(size(solN, 2) == 50, 'Invalid number of returned features.');
    
    solFound = ismember(solN(1:2, :)', poolSignsN', 'rows');
    assert(all(solFound), ...
      'Invalid results - retrieved feature not found in the pool.');
    assert(all(solN(:, 1) == querySignsN(:, qi)), ...
      'Invalid results - query feature not found as the first retrieved value.');
    
    cluster = clusters{queryClusters(qi)};
    isValid = ismember(solN(1:2,:)', cluster', 'rows');
    [~, ~, info] = vl_pr(isValid(2:end) * 2 - 1, -(2:numel(isValid)));
    if isnan(info.ap), info.ap = 0; end
    aps{ti}(qi) = info.ap;
    apsCh{ti}(qi) = (clustersNPatches(queryClusters(qi)) - 1) / (poolNPathces - 1);
    ri = ri + 1;
  end  
  updt(ti);
end
out = struct('ap', cell2mat(aps), 'apChance', cell2mat(apsCh), ...
  'numbenchmarks', size(benchmarks, 2));
end

function numSigns = decodeSigns(imdb, line)
% Encode set of signatures into an unique numeric vector
signs = strsplit(line, ',');
numSigns = cell2mat(cellfun(@(s) imdb.decodeSignature(s, true), signs, ...
  'UniformOutput', false));
end
