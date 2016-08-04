function matching_compute( imdb, benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

benchmarks = utls.readfile(benchpath);
vl_xmkdir(fileparts(outpath));

updt = utls.textprogressbar(numel(benchmarks));
fo = fopen(outpath, 'w');  assert(fo > 0, 'Unable to open %s', outpath);
for ti = 1:numel(benchmarks);
  fprintf(fo, '%s\n', benchmarks{ti});
  singatures = strsplit(benchmarks{ti}, ',');
  
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

