function res = verification( des, varargin)
%VERIFICATION Run the patch verification task
%  RES = VERIFICATION(DESCRIPTOR) Compute the results for descriptor
%  DESCRIPTOR. Descriptor can either be an object of `desc.memdesc` or a
%  string, in which case a descriptor from 
%
%     `<HBROOT>/data/descriptors/DESCRIPTOR`
%
%  are loaded.
%  Stores the results in csv files in:
%
%      `<HBROOT>/matlab/results/default/DESCRIPTOR/verification.csv`
%
%  If the scores file already exists, skips the computation. Use
%  `'override', true` to change this behaviour.
%
%  Additionally accepts the following 'OptionName', OptionValue arguments:
%
%  'scoresroot' :: '<HBROOT>/matlab/results/default/'
%   Change for a different target path for scores.
%   
%  'taskpath' :: '<HBROOT>/tasks'
%   Location of te tasks files.
%
%  'geom_noise' :: {'easy', 'hard', 'tough'}
%  Limit the geometry noise used for positives.
%
%  'negs' :: {'inter', 'intra'}
%  Used negative sets.
%
%  'split' :: {'a', 'b', 'c', 'illum', 'view', 'full'}
%  Limit the splits on which the scores are computed.
%
%  'override' :: false
%   If true, do override existing score file.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if ischar(des), [des, varargin] = desc.memdesc(des, varargin{:}); end;
opts.scoresroot = fullfile(hb_path, 'matlab', 'scores', 'default');
[opts, varargin] = vl_argparse(opts, varargin);
opts.taskspath = fullfile(hb_path, 'tasks');
opts.scorespath = fullfile(opts.scoresroot, des.name, 'verification.csv');
opts.split = {'a', 'b', 'c', 'illum', 'view', 'full'};
opts.negs = {'inter', 'intra'};
opts.geom_noise = {'easy', 'hard', 'tough'};
opts.methods = struct('name', {'balanced', 'imbalanced'}, ...
  'args', {{}, {'posneg_ratio', 0.2}});
opts.override = false;
opts.verbose = false;
[opts, ~] = vl_argparse(opts, varargin);

if opts.verbose, display(opts); end;
if ~iscell(opts.split), opts.split = {opts.split}; end;
if ~iscell(opts.negs), opts.negs = {opts.negs}; end;
if ~iscell(opts.geom_noise), opts.geom_noise  = {opts.geom_noise}; end;
vl_xmkdir(fileparts(opts.scorespath));
if ~opts.override && exist(opts.scorespath, 'file')
  res = readtable(opts.scorespath);
  fprintf('Results loaded from %s.\n', opts.scorespath);
  return;
end;

pospairs = @(split) fullfile(opts.taskspath, ...
  sprintf('verif_pos_split-%s.csv', split));
negpairs = @(split, neg) fullfile(opts.taskspath, ...
  sprintf('verif_neg_%s_split-%s.csv', neg, split));

numtasks = numel(opts.split)*numel(opts.negs)*numel(opts.geom_noise);
status = utls.textprogressbar(numtasks, 'updatestep', 1, ...
  'startmsg', sprintf('Evaluating "verification" for %s ', des.name));
stepi = 1;
res = {};
descs_n = des;
for gni = 1:numel(opts.geom_noise)
  gnoise = opts.geom_noise{gni};
  for si = 1:numel(opts.split)
    split = opts.split{si};
    pos_dists = bench.verification.compute(pospairs(split), descs_n, gnoise);
    for ni = 1:numel(opts.negs)
      neg = opts.negs{ni};
      neg_dists = bench.verification.compute(negpairs(split, neg), descs_n, gnoise);
      for mi = 1:numel(opts.methods)
        method = opts.methods(mi);
        res_s = bench.verification.eval(pos_dists, neg_dists, method.args{:});
        res{end+1} = struct(...
          'descriptor', descs_n.name, 'split', split, 'negs', neg, ...
          'geom_noise', gnoise, 'method', method.name, ...
          'pr_auc', res_s.pr_auc, 'pr_ap', res_s.pr_ap, 'roc_auc', res_s.roc_auc);
      end
      status(stepi); stepi = stepi+1;
    end
  end
end
res = struct2table(cell2mat(res), 'AsArray', true);
writetable(res, opts.scorespath);
fprintf('\n');

