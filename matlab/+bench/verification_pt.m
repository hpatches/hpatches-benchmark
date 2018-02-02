function res = verification_pt( dess, varargin)
%VERIFICATION_PT Run the patch verification task on phototourism
%  RES = VERIFICATION_PT(DESCRIPTOR) Compute the results for descriptor
%  DESCRIPTOR. Descriptor can either be an object of `desc.memdesc` or a
%  string, in which case a descriptor from
%
%     `<HBROOT>/data/descriptors-pt/DESCRIPTOR`
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
if ischar(dess), [dess, varargin] = desc.memdesc(dess, 'dataset', 'pt', varargin{:}); end;
opts.scoresroot = fullfile(hb_path, 'matlab', 'scores', 'default');
[opts, varargin] = vl_argparse(opts, varargin);
opts.scorespath = fullfile(opts.scoresroot, dess.name, 'verification-pt.csv');
opts.sequences = {'liberty', 'yosemite', 'notredame'};
opts.tasks = {'m50_100000_100000_0'};
opts.addProps = {};
opts.override = false;
opts.loadOnly = false;
opts.verbose = false;
opts.metric = 'L2';
[opts, varargin] = vl_argparse(opts, varargin);

if ~iscell(opts.sequences), opts.sequences = {opts.sequences}; end
if ~iscell(opts.tasks), opts.sequences = {opts.tasks}; end
if opts.verbose, display(opts); end
vl_xmkdir(fileparts(opts.scorespath));
if ~opts.override && exist(opts.scorespath, 'file')
  res = readtable(opts.scorespath);
  fprintf('Results loaded from %s.\n', opts.scorespath);
  return;
elseif opts.loadOnly
  res = [];
  return;
end


numtasks = numel(opts.sequences)*numel(opts.tasks);
status = utls.textprogressbar(numtasks, 'updatestep', 1, ...
  'startmsg', sprintf('Evaluating "verification-pt" for %s ', dess.name));
step = 1;
res = cell(numtasks, 1);
for si = 1:numel(opts.sequences)
  sequence = opts.sequences{si};
  for ti = 1:numel(opts.tasks)
    task = opts.tasks{ti};
    pairspath = fullfile(hb_path('pt'), sequence, [task '.txt']);
    pairs = dlmread(pairspath, ' ');
    pidA = pairs(:, 1)+1; pidB = pairs(:, 4)+1;
    tdpA = pairs(:, 2)+1; tdpB = pairs(:, 5)+1;
    
    descA = dess.getdesc(dess, sequence, pidA);
    descB = dess.getdesc(dess, sequence, pidB);
    
    switch opts.metric
      case 'L1'
        dists = sum(abs(descA - descB), 1);
      case 'L2'
        dists = sum((descA - descB).^2, 1);
      otherwise
        error('Invalid metric.');
    end
    
    labels = (tdpA == tdpB) * 2 - 1;
    [tpr, tnr, info_roc] = vl_roc(labels, -dists);
    [recall, precision, info_pr] = vl_pr(labels, -dists);
    
    res{step} = struct(...
      'descriptor', dess.name, 'sequence', sequence, 'task', task, ...
      'pr_ap', info_pr.ap, 'pr_auc', info_pr.auc, ...
      'roc_auc', info_roc.auc, ...
      'numpos', sum(labels==1), 'numneg', sum(labels==-1));
    status(step);
    step = step + 1;
  end
end

res = struct2table(cell2mat(res), 'AsArray', true);
writetable(res, opts.scorespath);
fprintf('\n');

