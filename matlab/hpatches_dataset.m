function imdb = hpatches_dataset(varargin)
p = inputParser();
addOptional(p, 'rootDir', fullfile('..','data','hpatches'), @(x) exist(x, 'dir'));
addOptional(p, 'matDir', fullfile('data', 'hpatches_mat'), @(x) exist(x, 'dir'));
addOptional(p, 'patchImages', {'ref', ...
  'e1', 'e2', 'e3', 'e4', 'e5', ...
  'h1', 'h2', 'h3', 'h4', 'h5'});
parse(p, varargin{:}); opts = p.Results;

assert(exist(opts.rootDir, 'dir') == 7, 'Dataset dir does not exist.');
sequences = sort(utls.listdirs(opts.rootDir));
tstFile = fopen(fullfile(opts.rootDir, 'test_set.txt'), 'r');
testSeqD = textscan(tstFile, '%s', 'delimiter', '\n'); fclose(tstFile);
[~, testSeq] = cellfun(@fileparts, testSeqD{1}, 'UniformOutput', false);
[testSeqFound, testSequences] = ismember(testSeq, sequences);
isTestSeq = false(1, numel(sequences)); isTestSeq(testSequences) = true;
assert(all(testSeqFound), 'Some test sequences not found, invalid data?');
[isTestSeq, tOrder] = sort(isTestSeq); sequences = sequences(tOrder);

imdb.data = {};
imdb.sequences.name = sequences;
imdb.sequences.set = ones(1, numel(sequences));
imdb.sequences.set(isTestSeq) = 3;
imdb.meta.patchimages = opts.patchImages;
imdb.meta.seq2idx = containers.Map(sequences, 1:numel(sequences));
imdb.meta.im2idx = containers.Map(opts.patchImages, 1:numel(opts.patchImages));

if ~exist(opts.matDir, 'dir'), mkdir(opts.matDir); end
getPatchPath = @(seqidx, imidx) fullfile(opts.rootDir, sequences{seqidx}, ...
  [opts.patchImages{imidx}, '.png']);
getMatPath = @(seqidx) fullfile(opts.matDir, [sequences{seqidx}, '.mat']);

data = cell(1, numel(sequences));
nsteps = numel(sequences) * numel(opts.patchImages); nsi = 1;
updt = utls.textprogressbar(nsteps);
for seqi = 1:numel(sequences)
  updt(nsi);
  matFile = getMatPath(seqi);
  psize = utls.get_image_size(getPatchPath(seqi, 1));
  npatches = psize(1)/psize(2);
  datasize = [psize(2), psize(2), 1, npatches, numel(opts.patchImages)];
  if exist(matFile, 'file') % Attempt to load existing file
    data{seqi} = matfile(matFile, 'Writable', false);
    if ~all(data{seqi}.datasize == datasize)
      data{seqi} = []; % Invalid data, recreate
    else
      updt(nsi); nsi = nsi + numel(opts.patchImages);
      continue;
    end
  end
  for imi = 1:numel(opts.patchImages)
    patches = imread(getPatchPath(seqi, imi));
    assert(all(size(patches) == psize(1:2)), 'Invalid patches');
    if isempty(data{seqi})
      data{seqi} = matfile(matFile, 'Writable', true);
      data{seqi}.data = zeros(datasize, 'like', patches);
      data{seqi}.datasize = datasize;
    end
    patches = mat2cell(patches, psize(2)*ones(1, npatches), psize(2));
    patches = permute(patches, [2, 3, 4, 1]);
    data{seqi}.data(:,:,:,:,imi) = cell2mat(patches);
    updt(nsi); nsi = nsi + 1;
  end
end
imdb.data = data;
imdb.getPatches = @(varargin) getpatches(imdb, varargin{:});
imdb.createSignature = @(varargin) createsignature(imdb, varargin{:});
fprintf('\n');
end

function [sequence, imagename, patches] = decode_signature(signature)
C = strsplit(signature, '.');
if numel(C) < 2 || numel(C) > 3, error('Invalid signature.'); end;
[sequence, imagename] = deal(C{:});
patches = ':';
% Signatures are zero based
if numel(C) > 2, patches = str2double(C{3}) + 1; end
end

function sign = createsignature(imdb, seq, imnm, patches)
if isscalar(seq), seq = imdb.sequences.name{seq}; end;
sign = seq;
if nargin > 2
  if isscalar(imnm), imnm = imdb.meta.patchimages(imnm); end;
  sign = [sign, '.' imnm];
  if nargin > 3
    assert(isscalar(patches), 'Invlaid patches def.');
    sign = [sign, '.', sprintf('%d', patches)];
  end;
end
end

function data = getpatches(imdb, sequence, imagename, patches)
assert(nargin > 0);
if nargin == 2 && strfind(sequence, '.')
  [sequence, imagename, patches] = decode_signature();
end
if strcmp(imagename, ':') && ~strcmp(patches, ':')
  error('Invalid indexing.');
end
seqidx = imdb.meta.seq2idx(sequence);
if nargin == 2 || strcmp(imagename, ':')
  data = imdb.data{seqidx};
  return;
end
if ischar(imagename) || iscell(imagename)
  if ~iscell(imagename), imagename = {imagename}; end;
  imidx = cellfun(@(imn) imdb.meta.im2idx(imn), imagename);
else
  imidx = imagename;
  assert(all(imidx > 0), all(imidx <= numel(imdb.meta.patchimages)));
end
if nargin < 3
  patches = 1:size(imdb.data{seqidx}, 3);
end
data = imdb.data{seqidx}.data(:,:,:,patches,imidx);
end