function retrieval_compute( imdb, benchpath, descfun, outpath, varargin )
opts.cacheName = '';
opts.topN = 50;
opts.maxNumComparisons = 0;
opts = vl_argparse(opts, varargin);

benchmarks = reshape(utls.readfile(benchpath), 3, []);

fo = fopen(outpath, 'w');
gupdt = utls.textprogressbar(size(benchmarks, 2));
for ti = 1:size(benchmarks, 2)
  fprintf('\nComputing task %d/%d.\n', ti, size(benchmarks, 2));
  fprintf(fo, '%s\n', benchmarks{1, ti});
  % Load the descriptors pool
  poolSignatures = strsplit(benchmarks{2, ti}, ',');
  fprintf('Computing the descriptor pool (%d patch images).\n', ...
    numel(poolSignatures));
  descPool = cell(1, numel(poolSignatures));
  descPoolLabels = cell(1, numel(poolSignatures));
  updt = utls.textprogressbar(numel(poolSignatures));
  for pi = 1:numel(poolSignatures)
    signature = poolSignatures{pi};
    [seq, im, fid] = imdb.decodeSignature(signature);
    assert(isnan(fid), 'Invalid signature');
    descPool{pi} = get_descriptors(imdb, signature, descfun, ...
      'cacheName', opts.cacheName);
    descPoolLabels{pi} = [...
      imdb.meta.seq2idx(seq)*ones(1, size(descPool{pi}, 2)); ...
      imdb.meta.im2idx(im)*ones(1, size(descPool{pi}, 2)); ...
      1:size(descPool{pi}, 2)];
    updt(pi);
  end
  descPool = cell2mat(descPool);
  descPoolInfo = whos('descPool');
  fprintf('Desc pool size: %.2fMiB.\n', descPoolInfo.bytes ./ 1024^2);
  descPoolLabels = cell2mat(descPoolLabels);
  
  % Do the matching
  fprintf('Building the KD-Tree... '); stime = tic;
  tr = vl_kdtreebuild(descPool);
  fprintf('Done in %.2fs.\n', toc(stime));
  
  querySignatures = strsplit(benchmarks{3, ti}, ',');
  qDesc = cell(1, numel(querySignatures));
  fprintf('Computing %d queries descriptors.\n', numel(querySignatures));
  for qi = 1:numel(querySignatures)
    qDesc{qi} = get_descriptors(imdb, querySignatures{qi}, descfun);
  end
  qDesc = cell2mat(qDesc);
  
  fprintf('Matching top-%d %d queries -> %d descriptors. ', opts.topN, ...
    size(qDesc, 2), size(descPool, 2)); stime = tic();
  pIdxs = vl_kdtreequery(tr, descPool, qDesc, 'numNeighbors', opts.topN, ...
    'maxNumComparisons', opts.maxNumComparisons);
  fprintf('Done in %.2f.\n', toc(stime));
  
  for qi = 1:numel(querySignatures)
    resSignatures = cell(1, opts.topN);
    for si = 1:opts.topN
      didx = pIdxs(si, qi); lbl = descPoolLabels(:, didx);
      resSignatures{si} = imdb.encodeSignature(lbl(1), lbl(2), lbl(3));
    end
    fprintf(fo, '%s\n', strjoin(resSignatures, ','));
  end
  fprintf('\n'); gupdt(ti);
end
fclose(fo);

end