function matching_compute( imdb, benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

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
  
  % Compute the descriptors
  descA = get_descriptors(imdb, singatures{1}, descfun, opts);
  descB = get_descriptors(imdb, singatures{2}, descfun, opts);
  
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

