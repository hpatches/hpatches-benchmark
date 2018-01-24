function desc = l2net( patches, varargin )
%L2NET MATLAB wrapper of L2 net.
%
%  Additionally accepts various optional arguments of the algorihm.
%  See [1] for details.
%
%  [1] Y. Tian, B. Fan, F. Wu. "L2-Net: Deep Learning of Discriminative
%   Patch Descriptor in Euclidean Space", CVPR, 2017.
%
% Copyright (C) 2018 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).


opts.url = 'https://github.com/yuruntian/L2-Net/archive/master.zip';
opts.rootDir = fullfile(hb_path('vendor'), 'l2net');
[opts, varargin] = vl_argparse(opts, varargin);
opts.binDir = fullfile(opts.rootDir, 'L2-Net-master');
opts.modelsDir = fullfile(opts.binDir, 'matlab');
[opts, varargin] = vl_argparse(opts, varargin);
opts.trainSet = 'LIB';
opts.flagCS = 1;
opts.flagAug = 1;
opts.flagGpu = gpuDeviceCount() > 0;
opts.binary = false;
opts.batchSize = 1000;
opts = vl_argparse(opts, varargin);

utls.setup_matconvnet();
if ~exist('cal_L2Net_des.m', 'file')
  utls.provision(opts.url, opts.rootDir, 'forceExt', '.zip');
  addpath(opts.modelsDir);
end

if size(patches, 1) ~= 64 || size(patches, 2) ~= 64
  patches = imresize(patches, [64, 64]);
end

desc = cal_L2Net_des(opts.modelsDir, opts.trainSet, opts.flagCS, ...
  opts.flagAug, patches, opts.batchSize, opts.flagGpu);

if opts.binary
  desc(desc>0) = 1;
  desc(desBinary<=0) = 0;
end

end

