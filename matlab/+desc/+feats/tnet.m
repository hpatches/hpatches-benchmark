function desc = tnet( patches, varargin )
%L2NET MATLAB wrapper of L2 net.
%
%  Additionally accepts various optional arguments of the algorihm.
%  See [1] for details.
%
%  [1] Y. Tian, B. Fan, F. Wu. "L2-Net: Deep Learning of Discriminative
%   Patch Descriptor in Euclidean Space", CVPR, 2017.
%
% Based on [2] by Karel Lenc
% [2] https://github.com/vijaykbg/deep-patchmatch/blob/master/code/feature_extract.m
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).


opts.url = 'https://github.com/vijaykbg/deep-patchmatch/archive/master.zip';
opts.rootDir = fullfile(hb_path('vendor'), 'tnet');
[opts, varargin] = vl_argparse(opts, varargin);
opts.binDir = fullfile(opts.rootDir, 'deep-patchmatch-master');
opts.modelsDir = fullfile(opts.binDir, 'models');
[opts, varargin] = vl_argparse(opts, varargin);
opts.modelPath = fullfile(opts.modelsDir, 'embedding', 'model_global_triplet_liberty.mat');
opts.flagGpu = gpuDeviceCount() > 0;
opts.batchSize = 1000;
opts = vl_argparse(opts, varargin);

utls.setup_matconvnet();
if ~exist(opts.modelPath , 'file')
  utls.provision(opts.url, opts.rootDir, 'forceExt', '.zip');
end

if size(patches, 1) ~= 64 || size(patches, 2) ~= 64
  patches = imresize(patches, [64, 64]);
end

ndata = load(opts.modelPath);
ndata.net = vl_simplenn_tidy(ndata.net);
assert(size(patches, 3) == 1);
N = size(patches, 4);
patches = single(bsxfun(@minus, single(patches), ndata.averageImage));
if opts.flagGpu
  ndata.net = vl_simplenn_move(ndata.net,'gpu');
end
dim = length(ndata.net.layers{end-1}.weights{2});
desc = zeros(N,dim);
tot_batch = ceil(N/opts.batchSize);
for i = 1:tot_batch
  im = patches(:,:,1,(i-1)*opts.batchSize+1:min(i*opts.batchSize,N));
  if opts.flagGpu
    im = gpuArray(im);
  end
  res = vl_simplenn(ndata.net,im,[]);  
  desc((i-1)*opts.batchSize+1:min(i*opts.batchSize,N),:) = gather(squeeze(res(end).x))';
end
desc = desc';
end

