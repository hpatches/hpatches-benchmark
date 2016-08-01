function matching_compute( imdb, benchpath, descfun, outpath )
assert(exist(benchpath, 'file') == 2, ...
  'Benchmark file %s does not exist.', benchpath);

fd = fopen(benchpath, 'r');
tasks = textscan(fd, '%s', 'delimiter', '\n'); tasks = tasks{1};
fclose(fd);

updt = utls.textprogressbar(numel(tasks));
fo = fopen(outpath, 'w');
for ti = 1:numel(tasks);
  fprintf(fo, '%s\n', tasks{ti});
  singatures = strsplit(tasks{ti}, ',');
  patchesA = imdb.getPatches(singatures{1});
  patchesA = reshape(patchesA, size(patchesA, 1), size(patchesA, 2), []);
  patchesB = imdb.getPatches(singatures{2});
  patchesB = reshape(patchesB, size(patchesB, 1), size(patchesB, 2), []);
  
  % Compute the descriptors
  descA = descfun(patchesA);
  assert(size(descA, 2) == size(patchesA, 3));
  descB = descfun(patchesB);
  assert(size(descB, 2) == size(patchesB, 3));
  
  % Do the matching
  tr = vl_kdtreebuild(descB);
  [idx, dist] = vl_kdtreequery(tr, descB, descA);
  
  % Write to a file (values are zero-indexed)
  daStr = sprintf('%d,', (1:size(descA, 2)) - 1);
  dbStr = sprintf('%d,', idx - 1);
  distStr = sprintf('%.6g,', dist);
  fprintf(fo, '%s\n%s\n%s\n', daStr(1:end-1), dbStr(1:end-1), distStr(1:end-1));
  
  updt(ti);
end
fclose(fo);
end

