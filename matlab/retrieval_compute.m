function retrieval_compute( benchpath, descfun, outpath, varargin )
% RETRIEVAL_COMPUTE Compute the results file for a retrieval task file
%  RETRIEVAL_COMPUTE(BENCH_FILE, DESC_FUN, OUTPATH) Computes the
%  results for a retrieval task defined in BENCH_FILE using the DESC_FUN for
%  computing descriptors. Stores the results in OUTPATH.
%
%  Additionally accepts the following name value pair arguments:
%
%  cacheName :: ''
%    Name of the descriptors cache.
%
%  imdb :: hpatches_dataset
%    Imdb to be used to retrieve the patches.
%
%  topN :: 51
%    Number of retrieved descriptors.
%
%  macNumComparison :: 0
%    Set to a positive value to use ANN.
%
%  debug :: false
%    Set to true to plot the retrieved patches.
%
%  See also: retrieval_eval

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.cacheName = '';
opts.imdb = [];
opts.topN = 51;
opts.maxNumComparisons = 0;
opts.debug = false;
opts = vl_argparse(opts, varargin);
if isempty(opts.imdb), opts.imdb = hpatches_dataset(); end;
imdb = opts.imdb;
fprintf(isdeployed+1,...
  'Computing retrieval results:\n\tBENCHMARK=%s\n\tDESC=%s\n\tOUT=%s\n', ...
  benchpath, opts.cacheName, outpath);

benchmarks = utls.readfile(benchpath);
vl_xmkdir(fileparts(outpath));

fo = fopen(outpath, 'w'); assert(fo > 0, 'Unable to open %s', outpath);
% Write the header
fprintf(fo, '%s\n', benchmarks{1});
% Load the descriptors pool
poolSignatures = strsplit(benchmarks{1}, ',');
fprintf(isdeployed+1, 'Computing the descriptor pool (%d patch images).\n', ...
  numel(poolSignatures));
descPool = cell(1, numel(poolSignatures));
descPoolLabels = cell(1, numel(poolSignatures));
updt = utls.textprogressbar(numel(poolSignatures));
for pi = 1:numel(poolSignatures)
  signature = poolSignatures{pi};
  signatureN = imdb.decodeSignature(signature, true);
  descPool{pi} = get_descriptors(imdb, signature, descfun, ...
    'cacheName', opts.cacheName);
  descPoolLabels{pi} = [...
    repmat(signatureN, 1, size(descPool{pi}, 2));
    1:size(descPool{pi}, 2)];
  updt(pi);
end
descPool = cell2mat(descPool);
descPoolInfo = whos('descPool');
fprintf(isdeployed+1, 'Desc pool size: %.2fMiB. ', descPoolInfo.bytes ./ 1024^2);
descPoolLabels = cell2mat(descPoolLabels);

% Do the matching
fprintf(isdeployed+1, 'Building the KD-Tree... '); stime = tic;
tr = vl_kdtreebuild(descPool);
fprintf(isdeployed+1, 'Done in %.2fs.\n', toc(stime));

querySignatures = benchmarks(2:end);
qDesc = cell(1, numel(querySignatures)); stime = tic;
fprintf(isdeployed+1, 'Computing %d query descriptors...\n', numel(querySignatures));
updt = utls.textprogressbar(numel(querySignatures));
for qi = 1:numel(querySignatures)
  qDesc{qi} = get_descriptors(imdb, querySignatures{qi}, descfun, ...
    'cacheName', opts.cacheName);
  updt(qi);
end
qDesc = cell2mat(qDesc);
fprintf(isdeployed+1, 'Done in %.2fs.\n', toc(stime));

fprintf(isdeployed+1, 'Retrieving closest %d features for %d queries -> %d descriptors... ', ...
  opts.topN, size(qDesc, 2), size(descPool, 2)); stime = tic();
pIdxs = vl_kdtreequery(tr, descPool, qDesc, 'numNeighbors', opts.topN, ...
  'maxNumComparisons', opts.maxNumComparisons);
fprintf(isdeployed+1, 'Done in %.2f.\n', toc(stime));

fprintf(isdeployed+1, 'Writing the results... '); stime = tic;
resSignatures = cell(numel(querySignatures), opts.topN);
for qi = 1:numel(querySignatures)
  for si = 1:opts.topN
    didx = pIdxs(si, qi); lbl = descPoolLabels(:, didx);
    resSignatures{qi, si} = imdb.encodeSignature(imdb.sequences.name{lbl(1)}, ...
      imdb.sequences.images{lbl(1)}{lbl(2)}, lbl(3));
  end
  if ~strcmp(resSignatures{qi, 1}, querySignatures{qi})
    warning(['Phew, what a descriptor - query patch not retrieved as the first patch.',...
      'Applying a hotfix...']);
    [qDescFound, qDescPos] = ismember(querySignatures{qi}, resSignatures(qi, :));
    if ~qDescFound % Add artifically, issue another warning...
      warning('Invalid descriptor. Query descriptor not within top 50.');
    else
      resSignatures{qi, qDescPos} = resSignatures{qi, 1};
    end
    % This does not influence the evaluation score as the PR curve is
    % computed from the second retrieved point.
    resSignatures{qi, 1} = querySignatures{qi};
  end
  fprintf(fo, '%s\n', strjoin(resSignatures(qi,:), ','));
end
fprintf(isdeployed+1, 'Done in %.2f.\n', toc(stime));

if opts.debug
  patches = cellfun(@(s) imdb.getPatches(s), resSignatures(:), 'UniformOutput', false);
  figure(1); clf;
  imshow(vl_imarray(cell2mat(reshape(patches, 1, 1, [])), ...
    'Layout', [opts.topN, numel(querySignatures)]));
  title(sprintf('Retrieved patches for task %d', ti)); waitforbuttonpress;
end
fclose(fo);
end
