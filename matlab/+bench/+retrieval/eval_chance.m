function out = eval_chance( imdb, labelspath )
% RETRIEVAL_EVAL_CHANCE

% Read the files
labels = utls.readfile(labelspath);
poolSignatures = strsplit(labels{1}, ',');
% Compare the headers
numQueries = numel(labels) - 1;
imRetAps = zeros(1, numQueries); patchRetAps = zeros(1, numQueries);
numAllFeats = sum(cellfun(@(sign) imdb.getNumPatches(sign), poolSignatures));
for lni = 2:numel(labels)
  query_cluster_descs = strsplit(labels{lni}, ',');  
  query_cluster_ims = remove_patchnum(query_cluster_descs);
  query_cluster_nfeats = sum(cellfun(@(sign) imdb.getNumPatches(sign), query_cluster_ims));
  
  imRetAps(lni) = (query_cluster_nfeats - 1) ./ (numAllFeats - 1);
  patchRetAps(lni) = (numel(query_cluster_descs) - 1) ./ (numAllFeats - 1);
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