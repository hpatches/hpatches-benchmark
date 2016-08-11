function classification_compute( imdb, benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

benchmarks = utls.readfile(benchpath);
vl_xmkdir(fileparts(outpath));

updt = utls.textprogressbar(numel(benchmarks));
fo = fopen(outpath, 'w');  assert(fo > 0, 'Unable to open %s', outpath);
for ti = 1:numel(benchmarks);
  singatures = strsplit(benchmarks{ti}, ',');
  
  descA = get_descriptors(imdb, singatures{1}, descfun, opts);
  descB = get_descriptors(imdb, singatures{2}, descfun, opts);
  assert(size(descA, 2) == 1, 'Invalid benchmark file.');
  assert(size(descB, 2) == 1, 'Invalid benchmark file.');
  
  dist = sum((descA - descB).^2);
  fprintf(fo, '%.6f\n', dist);
  updt(ti);
end
fclose(fo);
end