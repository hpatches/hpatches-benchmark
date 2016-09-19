function matching_compute( benchpath, descfun, outpath, varargin )
%MATCHING_COMPUTE Compute the results file for a matching task file
%  MATCHING_COMPUTE(BENCH_FILE, DESC_FUN, OUTPATH) Computes the
%  results for a matching task defined in BENCH_FILE using the DESC_FUN for
%  computing descriptors. Stores the results in OUTPATH.
%
%  Additionally accepts the following arguments:
%
%  cacheName :: ''
%    Name of the descriptors cache.
%
%  imdb :: hpatches_dataset
%    Imdb to be used to retrieve the patches.
%
%  See also: matching_eval

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.cacheName = '';
opts.imdb = [];
opts = vl_argparse(opts, varargin);
if isempty(opts.imdb), opts.imdb = hpatches_dataset(); end;
imdb = opts.imdb;

fprintf(isdeployed+1,...
  'Computing matching results:\n\tBENCHMARK=%s\n\tDESC=%s\n\tOUT=%s\n', ...
  benchpath, opts.cacheName, outpath);

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
  dist(isnan(dist)) = inf;
  
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
