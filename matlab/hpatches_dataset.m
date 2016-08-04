function imdb = hpatches_dataset(varargin)
funpath = fileparts(mfilename('fullpath'));
opts.rootDir = fullfile(funpath, '..','data','hpatches');
opts.binDir = fullfile(funpath, 'data', 'hpatches-bincache');
opts.ext = '.png';
opts = vl_argparse(opts, varargin);

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
imdb.sequences.npatches = zeros(1, numel(sequences));
imdb.sequences.images = cell(1, numel(sequences));
imdb.meta.categories = {'illum', 'viewpoint'};
categories = zeros(1, numel(sequences));
categories(cellfun(@(x) strcmp(x(1:2), 'i_'), sequences)) = 1;
categories(cellfun(@(x) strcmp(x(1:2), 'v_'), sequences)) = 2;
assert(all(categories) > 0);
imdb.sequences.categories = categories;
imdb.meta.seq2idx = containers.Map(sequences, 1:numel(sequences));
imdb.meta.name = 'hpatch';
imdb.meta.rootDir = opts.rootDir;

if ~exist(opts.binDir, 'dir'), mkdir(opts.binDir); end
getImPath = @(seqidx, im) fullfile(opts.rootDir, sequences{seqidx}, [im, opts.ext]);
getBinPath = @(seqidx) fullfile(opts.binDir, [sequences{seqidx}, '.bin']);
getDonePath = @(seqidx) fullfile(opts.binDir, [sequences{seqidx}, '.done']);

data = cell(1, numel(sequences));
updt = utls.textprogressbar(numel(sequences));
for seqidx = 1:numel(sequences)
  ims = dir(fullfile(opts.rootDir, sequences{seqidx}, ['*', opts.ext]));
  ims = cellfun(@(fn) strrep(fn, opts.ext, ''), {ims.name}, ...
    'UniformOutput', false);
  ims = sort(ims); imsString = strjoin(ims, ',');
  binFile = getBinPath(seqidx); doneFile = getDonePath(seqidx);
  psize = utls.get_image_size(getImPath(seqidx, ims{1}));
  npatches = psize(1)/psize(2);
  imdb.sequences.npatches(seqidx) = npatches;
  imdb.sequences.images{seqidx} = ims;
  imdb.sequences.im2idx{seqidx} = containers.Map(ims, 1:numel(ims));
  datasize = [psize(2), psize(2), 1, npatches, numel(ims)];
  if exist(doneFile, 'file') && exist(binFile, 'file')
    doneIms = utls.readfile(doneFile);
    data{seqidx} = utls.BinaryData(binFile, true);
    if all(size(data{seqidx}) == datasize) && numel(doneIms) == 1 && ...
        strcmp(doneIms{1}, imsString)
      updt(seqidx); continue;
    else
      % Dataset has changed, delete the cache files.
      delete(doneFile); delete(binFile);
    end
  end
  if exist(utls.BinaryData.LOCK_FILE(binFile), 'file')
    delete(utls.BinaryData.LOCK_FILE(binFile));
  end
  data{seqidx} = utls.BinaryData.zeros(binFile, datasize, 'uint8');
  for imi = 1:numel(ims)
    patches = imread(getImPath(seqidx, ims{imi}));
    assert(all(size(patches) == psize(1:2)), 'Invalid patches');
    patches = mat2cell(patches, psize(2)*ones(1, npatches), psize(2));
    patches = permute(patches, [2, 3, 4, 1]);
    data{seqidx}(:,:,:,:,imi) = cell2mat(patches);
  end
  df = fopen(doneFile, 'w'); fprintf(df, imsString); fclose(df);
  updt(seqidx);
end
imdb.data = data;
imdb.getPatches = @(varargin) getpatches(imdb, varargin{:});
imdb.encodeSignature = @(varargin) encode_signature(imdb, varargin{:});
imdb.decodeSignature = @(varargin) decode_signature(imdb, varargin{:});
fprintf('\n');
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

function data = getpatches(imdb, sequence, imagename, patches)
assert(nargin > 1);
if nargin < 4, patches = nan; end; 
assert(numel(patches) == 1);
decoded = false;
if nargin == 2 && ~isempty(strfind(sequence, '.'))
  % Decode the signature
  [sequence, imagename, patches] = decode_signature(imdb, sequence);
  decoded = true;
end
seqidx = imdb.meta.seq2idx(sequence);
% Return patches for the whole sequence
if ischar(imagename) || iscell(imagename)
  if ~iscell(imagename), imagename = {imagename}; end;
  imidx = cellfun(@(imn) imdb.sequences.im2idx{seqidx}(imn), imagename);
end
if (nargin < 3 && ~decoded) || isnan(patches)
  data = imdb.data{seqidx}(:,:,:,:,imidx);
else
  assert(all(patches > 0) && all(patches <= imdb.sequences.npatches(seqidx)), ...
    'Invlaid patch indexes.');
  data = imdb.data{seqidx}(:,:,:,patches,imidx);
end
end