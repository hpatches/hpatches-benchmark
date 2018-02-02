function [desc, info] = mkd( patches, varargin )
%MKD MATLAB wrapper of Multiple-Kernel local-patch Descriptor
%  DESC = MKD(PATCHES) Computes the descriptors of given PATCHES.
%  Patches are a 4D tensor with patches along 4th dimension.
%
%  Additionally accepts various optional arguments of the algorihm.
%  See [1] for details.
%
%  [1] Mukundan, Arun and Tolias, Giorgos and Chum, Ondrej:
%  Multiple-Kernel Local-Patch Descriptor
%  BMVC 2017.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).


opts.url = 'https://github.com/gtolias/mkd/archive/master.zip';
opts.rootDir = fullfile(hb_path('vendor'), 'mkd');
[opts, varargin] = vl_argparse(opts, varargin);
opts.binDir = fullfile(opts.rootDir, 'mkd-master');
opts.modelsDir = fullfile(opts.binDir, 'precomp_bmvc2017');
opts.modelName = 'mkd_liberty.mat';
opts = vl_argparse(opts, varargin);

if ~exist('mkdw.m', 'file')
  utls.provision(opts.url, opts.rootDir, 'forceExt', '.zip');
  addpath(genpath(opts.binDir));
end

cmkd = load(fullfile(opts.modelsDir, opts.modelName));
cmkd = cmkd.cmkd;

desc = [];
ptime = 0;
for pi = 1:size(patches, 4)
  if size(patches, 1) ~= cmkd.s || size(patches, 2) ~= cmkd.s
    patch = imresize(im2double(patches(:,:,:,pi)), [cmkd.s, cmkd.s]);
  else
    patch = patches(:,:,:,pi);
  end
  if size(patch, 3) == 3, patch = rgb2gray(patch); end
  I = im2single(patch);
  stime = tic;
  d = mkdw(I, cmkd);
  ptime = ptime + toc(stime);
  if isempty(desc)
    desc = zeros(numel(d), size(patches, 4), 'single');
  end
  desc(:, pi) = d;
end
info.time = ptime;
end

