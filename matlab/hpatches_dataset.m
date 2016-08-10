function imdb = hpatches_dataset(varargin)
funpath = fileparts(mfilename('fullpath'));
opts.rootDir = fullfile(funpath, '..','data','hpatches');
opts.imext = '.png';
opts = vl_argparse(opts, varargin);

assert(exist(opts.rootDir, 'dir') == 7, 'Dataset dir does not exist.');
sequences = sort(utls.listdirs(opts.rootDir));
tstSplitPath = fullfile(opts.rootDir, 'test_set.txt');
if exist(tstSplitPath, 'file')
  tstSplitF = fopen(tstSplitPath, 'r');
  testSeqD = textscan(tstSplitF, '%s', 'delimiter', '\n'); fclose(tstSplitF);
  [~, testSeq] = cellfun(@fileparts, testSeqD{1}, 'UniformOutput', false);
  [testSeqFound, testSequences] = ismember(testSeq, sequences);
  isTestSeq = false(1, numel(sequences)); isTestSeq(testSequences) = true;
  assert(all(testSeqFound), 'Some test sequences not found, invalid data?');
  [isTestSeq, tOrder] = sort(isTestSeq); sequences = sequences(tOrder);
else
  isTestSeq = ismember(sequences, {'test'});
end

imdb.data = {};
imdb.sequences.name = sequences;
imdb.sequences.set = ones(1, numel(sequences));
imdb.sequences.set(isTestSeq) = 3;
imdb.sequences.npatches = zeros(1, numel(sequences));
imdb.sequences.images = cell(1, numel(sequences));
imdb.meta.categories = {'illum', 'viewpoint'};
categories = -ones(1, numel(sequences));
categories(cellfun(@(x) strcmp(x(1:2), 'i_'), sequences)) = 1;
categories(cellfun(@(x) strcmp(x(1:2), 'v_'), sequences)) = 2;
categories(cellfun(@(x) strcmp(x, 'z_test'), sequences)) = 0;
assert(all(categories) >= 0);
imdb.sequences.categories = categories;
imdb.meta.seq2idx = containers.Map(sequences, 1:numel(sequences));
imdb.meta.name = 'hpatch';
imdb.meta.rootDir = opts.rootDir;
imdb.meta.imext = opts.imext;

getImPath = @(opts, sequence, im) fullfile(opts.rootDir, sequence, [im, opts.imext]);

data = cell(1, numel(sequences));
updt = utls.textprogressbar(numel(sequences));
for seqidx = 1:numel(sequences)
  sequence = sequences{seqidx};
  ims = dir(fullfile(opts.rootDir, sequence, ['*', opts.imext]));
  ims = cellfun(@(fn) strrep(fn, opts.imext, ''), {ims.name}, ...
    'UniformOutput', false);
  ims = sort(ims);
  psize = utls.get_image_size(getImPath(opts, sequence, ims{1}));
  npatches = psize(1)/psize(2);
  imdb.sequences.npatches(seqidx) = npatches;
  imdb.sequences.images{seqidx} = ims;
  imdb.sequences.im2idx{seqidx} = containers.Map(ims, 1:numel(ims));
  updt(seqidx);
end
imdb.getPatches = @(signature) getpatches(imdb, signature);
imdb.getNumPatches = @(signature) getNumPatches(imdb, signature);
imdb.encodeSignature = @(varargin) encode_signature(imdb, varargin{:});
imdb.decodeSignature = @(varargin) decode_signature(imdb, varargin{:});
fprintf('\n');
end

function patches = loadpatches(imdb, sequence, imname)
impath = fullfile(imdb.meta.rootDir, sequence, [imname, imdb.meta.imext]);
patches = imread(impath);
npatches = size(patches, 1) ./ size(patches, 2);
assert(mod(npatches, 1) == 0, 'Invalid patch image height.');
patches = mat2cell(patches, size(patches, 2)*ones(1, npatches), size(patches, 2));
patches = permute(patches, [2, 3, 4, 1]);
patches = cell2mat(patches);
end

function np = getNumPatches(imdb, signature)
sequenceNum = decode_signature(imdb, signature, true);
np = imdb.sequences.npatches(sequenceNum(1));
end

function [sequence, imagename, patches] = decode_signature(imdb, signature, numeric)
assert(ischar(signature));
if nargin < 3, numeric = false; end;
C = strsplit(signature, '.');
if numel(C) < 2 || numel(C) > 3, error('Invalid signature.'); end;
[sequence, imagename] = deal(C{1:2});
assert(ismember(sequence, imdb.sequences.name), ...
  'Invalid sequence name %s.', sequence);
seqidx = imdb.meta.seq2idx(sequence);
assert(ismember(imagename, imdb.sequences.images{seqidx}), ...
  'Invalid image name %s.', imagename);
patches = nan;
% Signatures are zero based
if numel(C) > 2, patches = str2double(C{3}) + 1; end
if numeric
  sequence = [seqidx; imdb.sequences.im2idx{seqidx}(imagename)];
  if ~isnan(patches), sequence = [sequence; patches]; end
end
end

function sign = encode_signature(imdb, seq, imnm, patches)
if isscalar(seq), seq = imdb.sequences.name{seq}; end;
sign = seq;
if nargin > 2
  assert(ischar(imnm));
  sign = [sign, '.' imnm];
  if nargin > 3
    seqidx = imdb.meta.seq2idx(seq);
    assert(isscalar(patches) && patches > 0 && ...
      patches <= imdb.sequences.npatches(seqidx), 'Invlaid patch index.');
    sign = [sign, '.', sprintf('%d', patches - 1)];
  end;
end
end

function data = getpatches(imdb, signature)
assert(nargin > 1);
[sequence, imagename, patches] = decode_signature(imdb, signature);
seqidx = imdb.meta.seq2idx(sequence);
data = loadpatches(imdb, sequence, imagename);
if ~isnan(patches) % sequence.imname
  assert(all(patches > 0) && all(patches <= imdb.sequences.npatches(seqidx)), ...
    'Invlaid patch index.');
  data = data(:,:,:,patches);
end
end