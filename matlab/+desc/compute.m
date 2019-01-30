function compute(desc_fun, varargin)
%COMPUTE Compute all descriptors for a dataset of patch images
%  COMPUTE(DESC_FUN) Computes descriptors for all patch images stored in:
%
%  `<HB_ROOT>/data/hpatches-release/SEQ_NAME/IMNAME.png`
%
%  and stores them in:
%
%  `<HB_ROOT>/data/descriptors/DESC_NAME/SEQ_NAME/IMNAME.csv`.
%
%  Descriptors are stored in a semicolon-separated file, with a descriptor
%  per line.
%  Descriptors name is by default guessed fromt he DESC_FUN. If DESC_FUN is
%  a string, a function from `+desc/+feats/DESC_FUN.m` is used.
%  A custom DESC_FUN should be passed as function reference and the
%  referred function should accept a single argument - a UINT8 tensor of
%  patches of size 65 x 65 x 1 x NUM_PATCHES for the HPatches dataset.
%
%  Additionally accepts the following arguments:
%
%  `datasetPath` :: `fullfile(hb_path, 'data', 'hpatches_v1.1')`
%    Change to use a different patches dataset.
%
%  `name` :: `func2str(DESC_FUN)`
%    Change to renamve the descriptor.
%
%  `imageExt` :: `*.png`
%    Change for different image format in the dataset.

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
p = inputParser();
p.addRequired('desc_fun', @(a) ischar(a) || isa(a,'function_handle'));
p.addParameter('dataset', 'hpatches');
p.addParameter('datasetPath', '', @(a) exist(a, 'dir'));
p.addParameter('destDir', '', @(a) exist(a, 'dir'));
p.addParameter('imageExt', '', @ischar);
p.addParameter('loadPatches', '', @(a) isa(a,'function_handle'));
p.addParameter('name', '', @ischar);
p.addParameter('descPackage', 'desc.feats.', @ischar);
p.addParameter('parallel', false, @islogical);
p.addParameter('override', false, @islogical);
p.parse(desc_fun, varargin{:});
opts = p.Results();

switch opts.dataset % Default values
  case {'hpatches', 'hp'}
    opts.datasetPath = hb_path('hp');
    opts.imageExt = '*.png';
    opts.loadPatches = @desc.load_hpatches;
    opts.destDir = hb_path('hp-desc');
  case {'phototourism', 'pt'}
    opts.datasetPath = hb_path('pt');
    opts.imageExt = '*.bmp';
    opts.loadPatches = @desc.load_phototourism;
    opts.destDir = hb_path('pt-desc');
  otherwise
    error('Ivalid dataset %s', opts.dataset);
end

datasetPath = opts.datasetPath;
if ischar(desc_fun)
  desc_fun = str2func([opts.descPackage, desc_fun]);
end
desc_name = opts.name;
if isempty(desc_name)
  % Create a name from the function name
  desc_name = strrep(func2str(desc_fun), opts.descPackage, '');
end

dest_dir = fullfile(opts.destDir, desc_name);
if ~exist(dest_dir, 'dir'), mkdir(dest_dir); end

sequences = utls.listdirs(datasetPath);
fprintf('Computing descriptor %s (@%s) for %d sequences.\n', ...
  desc_name, func2str(desc_fun), numel(sequences));
if opts.parallel
  parfor si = 1:numel(sequences)
    seq_name = sequences{si};
    compute_seq(datasetPath, dest_dir, desc_fun, seq_name, opts);
  end
else
  status = utls.textprogressbar(numel(sequences), 'startmsg', ...
  sprintf('Computing %s ', desc_name), 'updatestep', 1);
  for si = 1:numel(sequences)
    compute_seq(datasetPath, dest_dir, desc_fun, sequences{si}, opts);
    status(si);
  end
end

end


function compute_seq(datasetPath, dest_dir, desc_fun, seq_name, opts)
  seq_dir = fullfile(datasetPath, seq_name);
  dest_dir_seq = fullfile(dest_dir, seq_name);
  if ~exist(dest_dir_seq, 'dir'), mkdir(dest_dir_seq); end
  imgs = dir(fullfile(seq_dir, opts.imageExt));
  for imi = 1:numel(imgs)
    [~, imname, imext] = fileparts(imgs(imi).name);
    impath = fullfile(seq_dir, [imname, imext]);
    desc_path = fullfile(dest_dir_seq, [imname, '.csv']);
    if exist(desc_path, 'file') && ~opts.override, continue; end
    patches = opts.loadPatches(impath);
    des = desc_fun(patches);
    dlmwrite(desc_path, des', ';');
  end
end
