function [desc, info] = kde( patches, varargin )
%KDE Wrapper of the Kernel Local Descriptor
%  DESC = KDE(PATCHES) Computes the descriptors of given PATCHES.
%  Patches are a 4D tensor with patches along 4th dimension.
%
%  Additionally accepts various optional arguments of the algorihm.
%  See [1] for details.
%
%  [1] Bursuc, Andrei and Tolias, Giorgos and Jegou, Herve:
%  Kernel Local Descriptors with Implicit Rotation Matching.
%  ACM International Conference on Multimedia Retrieval, 2015.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

% Setup the descriptor

opts.url = 'https://github.com/abursuc/kde/archive/master.zip';
opts.rootDir = fullfile(hb_path('vendor'), 'kde');
[opts, varargin] = vl_argparse(opts, varargin);
opts.binDir = fullfile(opts.rootDir, 'kde-master');
[opts, varargin] = vl_argparse(opts, varargin);

if ~exist('kde.m', 'file')
  utls.provision(opts.url, opts.rootDir, 'forceExt', '.zip');
  addpath(fullfile(opts.binDir, 'kde'));
  addpath(fullfile(opts.binDir, 'helpers'));
end

s = size(patches, 1); % patch size
opts.kapparho = 8; % kappa for kernel on rho (radius in polar coordinates)
opts.kappaphi = 8; % kappa for kernel on phi (angle in polar coordinates)
opts.kappatheta = 8; % kappa for kernel on theta (relative gradient angle)
opts.nrho = 1; % number of frequencies for approx. of kernel on rho  
opts.nphi = 3; % number of frequencies for approx. of kernel on phi
opts.ntheta = 3; % number of frequencies for approx. of kernel on theta
opts = vl_argparse(opts, varargin);

% coefficients for the individual embeddings
crho = embcoef(opts.kapparho, opts.nrho);
cphi = embcoef(opts.kappaphi, opts.nphi);
ctheta = embcoef(opts.kappatheta, opts.ntheta);

% pre-compute phi-otimes-rho embedding for 64x64 positions
[epos, phi] = embfixedpos(cphi, crho, s);
pre.epos = epos; pre.phi = phi;
desc = [];
ptime = 0;
for pi = 1:size(patches, 4)
  I = single(patches(:, :, :, pi));
  stime = tic;
  d = kde(I, pre, ctheta);
  ptime = ptime + toc(stime);
  if isempty(desc)
    desc = zeros(numel(d), size(patches, 4), 'single');
  end
  desc(:, pi) = d;
end
info.time = ptime;
end

