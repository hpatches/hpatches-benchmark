function out = retrieval_eval( benchpath, labelspath, resultspath )
%RETRIEVAL_EVAL Evaluate the retrieval task results
%  RES = RETRIEVAL_EVAL(BENCHPATH, LABELSPATH, RESULTSPATH) Evaluates the
%  retrieval benchmark specified in BENCHPATH with labels stored in
%  LABELSPATH and results stored in RESULTSPATH.
%
%  Returns a structure array with values per image pair in mathcing task:
%    image_retr_ap  - APs per query for image retrieval task
%    patch_retr_ap  - APs per query for patch retrieval task
%
%  See also: retrieval_compute

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

fprintf(isdeployed+1, ...
  'Evaluating retrieval results:\n\tBENCHMARK=%s\n\tLABELS=%s\n\tRESFILE=%s\n', ...
  benchpath, labelspath, resultspath);

% Read the files
benchmarks = utls.readfile(benchpath);
labels = utls.readfile(labelspath);
results = utls.readfile(resultspath);

% Cmpare the headers
assert(strcmp(benchmarks{1}, labels{1}), 'Invalid header.');
assert(strcmp(benchmarks{1}, results{1}), 'Invalid headers.');
poolSignatures = strsplit(benchmarks{1}, ',');
assert(numel(benchmarks) == numel(labels), ...
  '#Queries in labels does not fit the #Queries in benchmark.');
assert(numel(benchmarks) == numel(results), ...
  '#Queries in results does not fit the #Queries in benchmark.');
numQueries = numel(benchmarks) - 1;

imRetAps = zeros(1, numQueries); patchRetAps = zeros(1, numQueries);
updt = utls.textprogressbar(numel(benchmarks) - 1);
for lni = 2:numel(benchmarks)
  query_desc = benchmarks{lni};
  query_cluster_descs = strsplit(labels{lni}, ',');
  retr_descs = strsplit(results{lni}, ',');
  
  % Check the task headers if they agree
  assert(ismember(query_desc, query_cluster_descs), ...
    'Invalid labels - query not found in its cluster.');
  assert(strcmp(query_desc, retr_descs{1}), ...
    'Invalid results - Query descriptor not the first retrieved desc.');
  assert(numel(retr_descs) == 51, 'Invalid number of retrieved features.');
  
  % Check that all retrieved features are from the cluster.
  retr_ims = remove_patchnum(retr_descs);
  assert(all(ismember(retr_ims, poolSignatures)), ...
    'Retrieved descriptors not part of the descriptor pool.');
  query_cluster_ims = remove_patchnum(query_cluster_descs);

  % Image retrieval
  isValid = ismember(retr_ims, query_cluster_ims); assert(isValid(1));
  [~, ~, info_imr] = vl_pr(isValid(2:end) * 2 - 1, -(2:numel(isValid)));
  if isnan(info_imr.ap), info_imr.ap = 0; end
  imRetAps(lni) = info_imr.ap;

  % Patch retrieval
  isValid = ismember(retr_descs, query_cluster_descs); assert(isValid(1));
  [~, ~, info_pr] = vl_pr(isValid(2:end) * 2 - 1, -(2:numel(isValid)));
  if isnan(info_pr.ap), info_pr.ap = 0; end
  patchRetAps(lni) = info_pr.ap;
  updt(lni);
end
out = struct('image_retr_ap', imRetAps, 'patch_retr_ap', patchRetAps);
end

function signs = remove_patchnum(signs)
% Get a sequence.imagename part of a signature
for si = 1:numel(signs)
  parts = strsplit(signs{si}, '.');
  assert(numel(parts) == 3, 'Invalid patch signature.');
  signs{si} = strjoin(parts(1:2), '.');
end
end