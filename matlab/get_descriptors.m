function [descriptors, proctime] = get_descriptors( imdb, signature, descfun, varargin )
% GET_DESCRIPTORS Compute descriptors and eventually cache them
opts.cachePath = fullfile(fileparts(mfilename('fullpath')), 'data', 'desc_cache');
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

if ~isempty(opts.cacheName)
  cachePath = fullfile(opts.cachePath, opts.cacheName, ...
    imdb.meta.name, [signature '.mat']);
  if exist(cachePath, 'file'), load(cachePath); return;
end

patches = imdb.getPatches(signature);
patches = reshape(patches, size(patches, 1), size(patches, 2), []);

stime = tic; descriptors = descfun(patches); proctime = toc(stime);
assert(size(descriptors, 2) == size(patches, 3), ...
  'Invalid number of descriptors returned.');

if ~isempty(opts.cacheName)
  vl_xmkdir(fileparts(cachePath));
  save(cachePath, 'descriptors', 'proctime');
end

end

