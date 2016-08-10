function [descriptors, proctime] = get_descriptors( imdb, signature, descfun, varargin )
% GET_DESCRIPTORS Compute descriptors and eventually cache them
opts.cachePath = fullfile(fileparts(mfilename('fullpath')), 'data', 'descriptors');
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

if ~isempty(opts.cacheName)
  signParts = strsplit(signature, '.');
  cachePath = fullfile(opts.cachePath, opts.cacheName, ...
    signParts{1}, [signParts{2}, '.csv']);
  if exist(cachePath, 'file')
    descriptors = single(dlmread(cachePath, ';')');
    if numel(signParts) == 3
      descriptors = descriptors(:, str2double(signParts{3}));
    end
    return;
  end
end

patches = imdb.getPatches(signature);
patches = reshape(patches, size(patches, 1), size(patches, 2), []);

stime = tic;
descriptors = single(descfun(signature, patches));
proctime = toc(stime);
assert(size(descriptors, 2) == size(patches, 3), ...
  'Invalid number of descriptors returned.');

if ~isempty(opts.cacheName) && numel(signParts) == 2
  vl_xmkdir(fileparts(cachePath));
  dlmwrite(cachePath, descriptors', ';');
end
end

