function [desc, varargin] = normdesc(desc, varargin)
%NORMDESC Descriptor normalisation
%  NORMDESC is a helper wrapper used for descriptor normalisation. By
%  default performs square root followed by L2 normalisation. NORMDESC
%  renames the descriptor -> stores results in a new path.
%
%  The order of the operations is (if enabled):
%    Whitening -> Power law normalisation -> L2 Normalisation
%
%  NORMDESC ... 'OptionName', 'OptionValue' can additionaly change:
%
%  norm_split :: 'a'
%    Selects a split used for learning the PCA/ZCA projection.
%
%  whiten :: ''
%    Either 'PCA' or 'ZCA' to enable PCA or ZCA whitening. Additionally
%    uses the following options:
%    clipeigen :: 0
%      If not zero, clip all the lowest eigen values of the selected
%      cumulative energy to its highest values [1]. E.g. with =1, sets all
%      eigen values to be equal to the highest eigen value.
%    epsilon :: 1e-6
%      The minimum factor used for the division operator in the PCA/ZCA
%      whitening. Similar effect as clipeigen.
%    dimReduction :: inf
%      Perform dimensionality reduction, if smaller than the descriptor
%      dimensionality.
%
%  pl :: 0.5
%    Perform power-law normalisation of the given factor. E.g. with 0.5,
%    uses the square root of the descriptor.
%
%  l2norm :: true
%    L2-normalise the descriptor to have magnitude of 1 in the L2 space,
%    when true.
%
%
%  [1] G. Hua, M. Brown, and S. Winder. Discriminant embedding
%      for local image descriptors. In ICCV, pages 1–8. IEEE, 2007

% Copyright (C) 2016-2017 Karel Lenc, Giorgos Tolias
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.norm_split = 'a';

opts.whiten = '';
opts.clipeigen = 0;
opts.epsilon = 1e-6;
opts.dimReduction = inf;

opts.pl = 0.5;
opts.l2norm = true;

opts.normstring = '';

[opts, varargin] = vl_argparse(opts, varargin); 
% Parse the norm string
opts = normstr2args(opts);
normstr = getnormstr(opts);

if ~isempty(desc)
  fprintf('Normalising the %s features (%s).\n', desc.name, normstr);
  dict = norm_computedict(desc, opts);
  dsz = size(desc.data);
  data = reshape(desc.data, dsz(1), []);
  data = norm_project(data, dict, opts);
  desc.data = reshape(data, dsz);
  desc.name = [desc.name, normstr];
end
desc.opts = opts;
end

function name = getnormstr(opts)
% Convert norm options to a string used as descriptor name
name = sprintf('_nsplit_%s', opts.norm_split);
if opts.whiten, name = [name, '_w', opts.whiten]; end;
if opts.clipeigen > 0, name = [name, sprintf('_ceig%.2f', opts.clipeigen)]; end;
if ~isinf(opts.dimReduction), name = [name, sprintf('_pcad%d', opts.dimReduction)]; end;
if opts.pl ~= 1, name = [name, sprintf('_pl%.2f', opts.pl)]; end;
if opts.l2norm, name = [name, '_l2n']; end;
end

function opts = normstr2args(opts)
% convert descriptor name to norm options
if isempty(opts.normstring), return; end;
normstr = opts.normstring;
args = {};
if ~isempty(strfind(normstr, 'l2n')), args = [args, {'l2norm', true}]; end;
if ~isempty(strfind(normstr, 'wzca')), args = [args, {'whiten', 'zca'}]; end;
if ~isempty(strfind(normstr, 'wpca')), args = [args, {'whiten', 'pca'}]; end;
match = regexp(normstr, 'pl(?<val>[0-9][_.][0-9]{1,})', 'names');
if ~isempty(match)
  args = [args, {'pl', str2double(strrep(match.val, '_', '.'))}];
end;
match = regexp(normstr, 'ceig(?<val>[0-9][_.][0-9]{1,})', 'names');
if ~isempty(match)
  args = [args, {'clipeigen', str2double(strrep(match.val, '_', '.'))}];
end;
match = regexp(normstr, 'nsplit_(?<val>[a-z]{1,})', 'names');
if ~isempty(match)
  args = [args, {'norm_split', match.val}];
end;
opts = vl_argparse(opts, args); 
end

function dict = norm_computedict(desc, opts)
splits = utls.parse_json(fullfile(hb_path, 'matlab', 'data', 'splits.json'));
dsz = size(desc.data);
[~, seq_sel] = ismember(splits.(opts.norm_split).train, desc.sequences);
desc_sel = ismember(desc.sequence, seq_sel);
assert(~isempty(desc_sel), 'Invalid selection.');

data = reshape(desc.data(:, desc_sel, :), dsz(1), []);
dict = struct();
[~, dict.eigvec, dict.eigval, dict.Xm] = utls.yael_pca(data);
end


function [ x ] = norm_project(x, dict, opts)

x = bsxfun (@minus, x, single(dict.Xm));  % Subtract the mean
if ~isempty(opts.clipeigen) && opts.clipeigen > 0 && opts.clipeigen < 1
  eigs_s = sort(abs(dict.eigval), 'ascend');
  eigs_ss = cumsum(eigs_s) ./ sum(eigs_s);
  eig_sel = eigs_s(find(eigs_ss > opts.clipeigen, 1));
  dict.eigval(abs(dict.eigval) < eig_sel) = eig_sel;
  fprintf('Clipping %d/%d eigen values.\n', ...
    sum(eigs_s < eig_sel), numel(eigs_s));
end
opts.dimReduction = min(opts.dimReduction, size(x, 1));
U = dict.eigvec;
switch opts.whiten
  case 'zca'
    U = U * diag(1./sqrt(dict.eigval + opts.epsilon)) * U';
  case 'pca'
    U = diag(1./sqrt(dict.eigval + opts.epsilon)) * U' ;
  otherwise
    U = diag(dict.eigval) * U';
end

if ~isempty(opts.whiten)
  x = single(U(:, 1:opts.dimReduction))' * x;
end

if opts.pl ~= 1
  % Apply power law
  x = sign (x) .* abs(x)  .^ opts.pl;
end

if opts.l2norm
  % L2 normalisation
  l = sqrt(sum(x.^2, 1));
  x = bsxfun(@rdivide, x, l);
end
% Replace nan values
x(isnan(x)) = 0;
end
