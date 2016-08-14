function classification_compute( benchpath, descfun, outpath, varargin )
%CLASSIFICATION_COMPUTE Compute the results file for a *.pairs file
%  CLASSIFICATION_COMPUT(BENCHPATH, DESC_FUN, OUTPATH) Computes the
%  distances between pairs specified in BENCHPATH using the DESC_FUN for
%  computing descriptors and stores the distances in OUTPATH.
%
%  Additionally accepts the following arguments:
%
%  cacheName :: ''
%    Name of the descriptors cache.
%
%  imdb :: hpatches_dataset
%    Imdb to be used to retrieve the patches.
%
%  See also: classification_eval

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

fprintf(isdeployed+1, 'Computing classif results:\n\tBENCH=%s\n\tDESC=%s\n\tOUT=%s\n', ...
  benchpath, opts.cacheName, outpath);
assert(~isempty(strfind(benchpath, '.benchmark')), 'Input must be a .benchmark file.');

% For a reasonable evaluation speed, descriptors are stored in memory so
% they do not have to be recomputed
cache = containers.Map();
  function desc = desc_memcache(imdb, sign, descfun, opts)
    [seq, im, patch] = imdb.decodeSignature(sign);
    imsign = [seq '.' im];
    if cache.isKey(imsign)
      desc = cache(imsign);
    else
      desc = get_descriptors(imdb, imsign, descfun, ...
        'cacheName', opts.cacheName);
      cache(imsign) = desc;
    end
    desc = desc(:, patch);
  end

pairs_files = utls.readfile(benchpath); assert(numel(pairs_files) == 2);
benchdir = fileparts(benchpath);
pairs = [utls.readfile(fullfile(benchdir, pairs_files{1}));
  utls.readfile(fullfile(benchdir, pairs_files{2}))];
vl_xmkdir(fileparts(outpath));

updt = utls.textprogressbar(numel(pairs));
fo = fopen(outpath, 'w'); assert(fo > 0, 'Unable to open %s', outpath);
for ti = 1:numel(pairs);
  singatures = strsplit(pairs{ti}, ',');
  assert(numel(singatures) == 3, 'Invalid pairs file.');
  descA = desc_memcache(imdb, singatures{1}, descfun, opts);
  descB = desc_memcache(imdb, singatures{2}, descfun, opts);
  assert(size(descA, 2) == 1, 'Invalid pairs file.');
  assert(size(descB, 2) == 1, 'Invalid pairs file.');
  
  dist = sum((descA - descB).^2);
  fprintf(fo, '%.6f,%s\n', dist, singatures{end});
  updt(ti);
end
fclose(fo);
end