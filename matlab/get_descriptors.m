function [descriptors, cachePath] = get_descriptors( imdb, signature, descfun, varargin )
%GET_DESCRIPTORS Compute descriptors and eventually cache them
%  DESC = GET_DESCRIPTORS(IMDB, SIGNATURE, DESCFUN) Compute descriptors
%  using the DESCFUN for a patch with SIGNATURE from the IMDB. The DESCFUN
%  must be a function with signature:
%
%    DESC = DESCFUN(SIGNATURE, PATCHES)
%
%  Additionally the function accepts the following arguments:
%
%  cacheName :: ''
%    When specified, cache the descriptors in csv files in folder defined
%    by the `cachePath` argument. If empty, cache is not used. When caching
%    enabled and the function is called with a patch signature, descriptors
%    of all patches within a single image are computed and cached.
%
%  cachePath :: fullfile(hb_path, 'data', 'descriptors')
%    Specify a different cachePath.

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.cachePath = fullfile(hb_path, 'data', 'descriptors');
opts.cacheName = '';
opts.postproc = @(x) x;
opts = vl_argparse(opts, varargin);

doCache = ~isempty(opts.cacheName); cachePath = [];
if doCache
  signParts = strsplit(signature, '.');
  cachePath = fullfile(opts.cachePath, opts.cacheName, ...
    signParts{1}, [signParts{2}, '.csv']);
  % Compute and cache descriptors for all patches in an image
  signature = [signParts{1}, '.' signParts{2}];
end

if doCache && exist(cachePath, 'file')
  descriptors = single(dlmread(cachePath)');
else
  patches = imdb.getPatches(signature);
  patches = reshape(patches, size(patches, 1), size(patches, 2), []);
  descriptors = single(descfun(signature, patches));
  assert(size(descriptors, 2) == size(patches, 3), ...
    'Invalid number of descriptors returned.');
  if doCache
    vl_xmkdir(fileparts(cachePath));
    dlmwrite(cachePath, descriptors', ';');
  end
end

if doCache && numel(signParts) == 3
  descriptors = descriptors(:, str2double(signParts{3}) + 1);
end

descriptors = opts.postproc(descriptors);
end

