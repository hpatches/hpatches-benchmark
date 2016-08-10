function descriptors = get_descriptors( imdb, signature, descfun, varargin )
% GET_DESCRIPTORS Compute descriptors and eventually cache them
opts.cachePath = fullfile(fileparts(mfilename('fullpath')), 'data', 'descriptors');
opts.cacheName = '';
opts = vl_argparse(opts, varargin);

signParts = strsplit(signature, '.');
cachePath = fullfile(opts.cachePath, opts.cacheName, ...
  signParts{1}, [signParts{2}, '.csv']);
if ~isempty(opts.cacheName) && exist(cachePath, 'file')
  descriptors = single(dlmread(cachePath, ';')');
else
  patches = imdb.getPatches([signParts{1}, '.' signParts{2}]);
  patches = reshape(patches, size(patches, 1), size(patches, 2), []);
  descriptors = single(descfun(signature, patches));
  assert(size(descriptors, 2) == size(patches, 3), ...
    'Invalid number of descriptors returned.');
  if ~isempty(opts.cacheName)
    vl_xmkdir(fileparts(cachePath));
    dlmwrite(cachePath, descriptors', ';');
  end
end
if numel(signParts) == 3
  descriptors = descriptors(:, str2double(signParts{3}));
end
end

