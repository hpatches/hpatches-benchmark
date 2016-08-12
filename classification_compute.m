function classification_compute( pairspath, descfun, outpath, varargin )
opts.cacheName = '';
opts.imdb = [];
opts = vl_argparse(opts, varargin);
if isempty(opts.imdb), opts.imdb = hpatches_dataset(); end;
imdb = opts.imdb;
if ischar(descfun)
  opts.cacheName = descfun;
  descfun = @desc_none;
end

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

pairs = utls.readfile(pairspath);
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