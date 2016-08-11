function retrieval_compute( imdb, benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts.topN = 51;
opts.maxNumComparisons = 0;
opts.debug = false;
opts = vl_argparse(opts, varargin);

benchmarks = utls.readfile(benchpath);
vl_xmkdir(fileparts(outpath));

fo = fopen(outpath, 'w'); assert(fo > 0, 'Unable to open %s', outpath);
% Write the header
fprintf(fo, '%s\n', benchmarks{1});
% Load the descriptors pool
poolSignatures = strsplit(benchmarks{1}, ',');
fprintf('Computing the descriptor pool (%d patch images).\n', ...
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
fprintf('Desc pool size: %.2fMiB. ', descPoolInfo.bytes ./ 1024^2);
descPoolLabels = cell2mat(descPoolLabels);

% Do the matching
fprintf('Building the KD-Tree... '); stime = tic;
tr = vl_kdtreebuild(descPool);
fprintf('Done in %.2fs.\n', toc(stime));

querySignatures = benchmarks(2:end);
qDesc = cell(1, numel(querySignatures)); stime = tic;
fprintf('Computing %d queries descriptors...\n', numel(querySignatures));
updt = utls.textprogressbar(numel(querySignatures));
for qi = 1:numel(querySignatures)
  qDesc{qi} = get_descriptors(imdb, querySignatures{qi}, descfun);
  updt(qi);
end
qDesc = cell2mat(qDesc);
fprintf('Done in %.2fs.\n', toc(stime));

fprintf('Retrieving closest %d features for %d queries -> %d descriptors... ', ...
  opts.topN, size(qDesc, 2), size(descPool, 2)); stime = tic();
pIdxs = vl_kdtreequery(tr, descPool, qDesc, 'numNeighbors', opts.topN, ...
  'maxNumComparisons', opts.maxNumComparisons);
fprintf('Done in %.2f.\n', toc(stime));

resSignatures = cell(numel(querySignatures), opts.topN);
for qi = 1:numel(querySignatures)
  for si = 1:opts.topN
    didx = pIdxs(si, qi); lbl = descPoolLabels(:, didx);
    resSignatures{qi, si} = imdb.encodeSignature(imdb.sequences.name{lbl(1)}, ...
      imdb.sequences.images{lbl(1)}{lbl(2)}, lbl(3));
  end
  assert(strcmp(resSignatures{qi, 1}, querySignatures{qi}), ...
    'Invalid descriptor - query patch not retrieved as the first patch.');
  fprintf(fo, '%s\n', strjoin(resSignatures(qi,:), ','));
end

if opts.debug
  patches = cellfun(@(s) imdb.getPatches(s), resSignatures(:), 'UniformOutput', false);
  figure(1); clf;
  imshow(vl_imarray(cell2mat(reshape(patches, 1, 1, [])), ...
    'Layout', [opts.topN, numel(querySignatures)]));
  title(sprintf('Retrieved patches for task %d', ti)); waitforbuttonpress;
end
fclose(fo);
end