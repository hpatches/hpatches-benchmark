function [obj, varargin] = memdesc(descname, varargin)
%MEMDESC Returns object with loaded descriptor and simple access methods
%  OBJ = MEMDESC(DESCNAME) Loads CSV descriptor from:
%
%     `<HB_ROOT>/data/descritpors/DESCNAME`
%
%  and returns an object with methods to access the descriptor data from
%  memory.
%
%  By default, creates a cache of the CSV descriptors in:
%
%     `<HB_ROOT>/data/descritpors/DESCNAME/descs.mat`
%
%  for faster loading. Call  MEMDESC(... 'matccache', false) to override
%  this behaviour and load the CSV descriptors.
%
%  Additionally accepts these options:
%
%  'dtype' :: 'single'
%     Data storage type class. Casted using 'cast' function.
%
%  'matcahce' :: true
%     Buffer the descriptors in `desc.mat` file as it leads to faster
%     loading time. Enabled by default.
%
%  'norm' :: false
%     Apply normalisation using `desc.normdesc`, passes over the unused
%     optional arguments.
%
%  'nanval' :: 0
%     Replace nan values in descriptor with the given value, zero by
%     default. Use NaN to keep the original descriptors.
%
%  See also:
%    desc.normdesc

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.dtype = 'single';
opts.matcache = true;
opts.norm = false;
opts.nanval = 0;
opts.noLoad = false;
[opts, varargin] = vl_argparse(opts, varargin);
if ischar(opts.norm), opts.norm = str2num(opts.norm); end;

% Just construct descriptor name
if opts.noLoad
  obj.name = descname;
  if opts.norm
    [obj, varargin] = desc.normdesc(obj, varargin{:});
  end
  return;
end

path = fullfile(hb_path, 'data', 'descriptors', descname);
cachepath = fullfile(path, 'desc.mat');

if ~exist(cachepath, 'file') || ~opts.matcache
  obj = load_desc(descname, path, opts);
  if opts.matcache
    fprintf('Saving CSV descriptors to MAT file %s.\n', cachepath);
    save(cachepath, '-v7.3', '-struct', 'obj');
  end
else
  fprintf('Loading cached descriptor from %s.\n', cachepath);
  obj = load(cachepath);
  obj.path = path;
  obj.name = descname;
end

if opts.norm
  [obj, varargin] = desc.normdesc(obj, varargin{:});
end

% Set up methods
obj.getdesc = @(obj, varargin) getdesc(obj, varargin{:});
obj.test_getdesc = @(obj, varargin) test_getdesc(obj, varargin{:});
obj.getimdescs = @(obj, varargin) getimdescs(obj, varargin{:});
obj.test_getimdescs = @(obj, varargin) test_getimdescs(obj, varargin{:});
end

function obj = load_desc(descname, path, opts)
obj.path = path;
obj.sequences = utls.listdirs(path);
obj.sequence = [];
obj.images = {'ref', 'e1', 'e2', 'e3', 'e4', 'e5', ...
  'h1', 'h2', 'h3', 'h4', 'h5', 't1', 't2', 't3', 't4', 't5'};
obj.sets = containers.Map({'easy', 'hard', 'tough'}, ...
  {[1, 2, 3, 4, 5, 6], [1, 7, 8, 9, 10, 11], [1, 12, 13, 14, 15, 16]});
obj.name = descname;
obj.ndescs = zeros(1, numel(obj.sequences));

numDescs = numel(obj.sequences) * numel(obj.images);
status = utls.textprogressbar(numDescs, 'startmsg', sprintf('Loading %s CSVs', descname));
stepi = 1;
gdesc = @(sequence, image) dlmread(fullfile(path, sequence, [image, '.csv']))';
obj.data = cell(1, numel(obj.sequences), numel(obj.images));
obj.sequence = cell(1, numel(obj.sequences));
for si = 1:numel(obj.sequences)
  name = obj.sequences{si};
  for imi = 1:numel(obj.images)
    d = cast(gdesc(name, obj.images{imi}), opts.dtype);
    d(isnan(d)) = opts.nanval;
    obj.data{1, si, imi} = d;
    stepi = stepi+1; status(stepi);
  end
  obj.sequence{1, si} = si*ones(1, size(obj.data{1, si, imi}, 2));
end
obj.ndescs = cellfun(@(a) size(a, 2), obj.data(1,:,1));
obj.data = cell2mat(obj.data);
obj.sequence = cell2mat(obj.sequence);
obj.offsets = [0, cumsum(obj.ndescs(1:end-1))];
end


function [descs, seqi] = getdesc(obj, sequences, geom_noise, images, idxs)
assert(numel(sequences) == numel(images));
assert(numel(sequences) == numel(idxs));
assert(all(idxs > 0), 'Indexes must be >0');
assert(ischar(geom_noise));
sequences = reshape(sequences, 1, []);
images = reshape(images, 1, []);
idxs = reshape(idxs, 1, []);
[~, seqi] = ismember(sequences, obj.sequences);
gn_set = obj.sets(geom_noise);
gni = gn_set(images);
idxs_o = idxs + obj.offsets(seqi);
sel = sub2ind([size(obj.data, 2), size(obj.data, 3)], idxs_o, gni);
data = reshape(obj.data, size(obj.data, 1), []);
descs = data(:, sel);
end

function descs = getimdescs(obj, sequence, geom_noise, image)
[~, seti] = ismember(sequence, obj.sequences);
gn_set = obj.sets(geom_noise);
idxs_o = (1:obj.ndescs(seti)) + obj.offsets(seti);
descs = obj.data(:, idxs_o, gn_set(image));
end

function test_getdesc(obj, sequences, geom_noise, images, idxs)
desc_a = obj.getdesc(sequences, geom_noise, images, idxs);
  function nm = getimname(geom_noise, image)
    if image==1, nm = 'ref';
    else nm = sprintf('%s%d', geom_noise(1), image - 1); end;
  end
getdesc = @(sequence, image) dlmread(fullfile(obj.path, sequence, [image, '.csv']))';
for si = 1:numel(sequences)
  fdesc = getdesc(sequences{si}, getimname(geom_noise, images(si)));
  desc_b = fdesc(:, idxs(si));
  assert(all(desc_a(:, si) == desc_b));
end
end

function test_getimdescs(obj, sequence, geom_noise, image)
desc_a = obj.getimdescs(sequence, geom_noise, image);
  function nm = getimname(geom_noise, image)
    if image==1, nm = 'ref';
    else nm = sprintf('%s%d', geom_noise(1), image - 1); end;
  end
getdesc = @(sequence, image) dlmread(fullfile(obj.path, sequence, [image, '.csv']))';
desc_b = getdesc(sequence, getimname(geom_noise, image));
assert(all(desc_a(:) == desc_b(:)));
end

