function matching_compute( benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts.imdb = [];
opts = vl_argparse(opts, varargin);
if isempty(opts.imdb), opts.imdb = hpatches_dataset(); end;
imdb = opts.imdb;
if ischar(descfun)
  opts.cacheName = descfun;
  descfun = @desc_none;
end

benchmarks = utls.readfile(benchpath);
vl_xmkdir(fileparts(outpath));

updt = utls.textprogressbar(numel(benchmarks));
fo = fopen(outpath, 'w');  assert(fo > 0, 'Unable to open %s', outpath);
for ti = 1:numel(benchmarks);
  fprintf(fo, '%s\n', benchmarks{ti});
  singatures = strsplit(benchmarks{ti}, ',');
  
  % Compute the descriptors
  descA = get_descriptors(imdb, singatures{1}, descfun, 'cacheName', opts.cacheName);
  descB = get_descriptors(imdb, singatures{2}, descfun, 'cacheName', opts.cacheName);
  assert(size(descA, 2) == size(descB, 2));
  
  % Do the matching
  tr = vl_kdtreebuild(descB);
  [idx, dist] = vl_kdtreequery(tr, descB, descA, 'NumNeighbors', 2);
  
  % Write to a file (values are zero-indexed)
  fprintf(fo, '%s\n', num2line(idx(1, :) - 1)); fprintf(fo, '%s\n', num2line(dist(1, :)));
  fprintf(fo, '%s\n', num2line(idx(2, :) - 1)); fprintf(fo, '%s\n', num2line(dist(2, :)));
  updt(ti);
end
fclose(fo);
end

function l = num2line(n)
l = sprintf('%d,', n);
l = l(1:end-1);
end