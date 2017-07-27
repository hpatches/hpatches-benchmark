function desc = kde( patches, varargin )
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
run(fullfile(hb_path, 'matlab', 'lib', 'kde', 'kde_setup,m'));

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
for pi = 1:size(patches, 4)
  I = single(patches(:, :, :, pi));
  d = kde(I, pre, ctheta);
  if isempty(desc)
    desc = zeros(numel(d), size(patches, 4), 'single');
  end
  desc(:, pi) = d;
end

end

