function res = retrieval( des, varargin )
% RETRIEVAL Run the image retrieval task
%  RES = RETRIEVAL(DESCRIPTOR) Compute the results for descriptor
%  DESCRIPTOR. Descriptor can either be an object of `desc.memdesc` or a
%  string, in which case a descriptor from 
%
%     `<HBROOT>/data/descriptors/DESCRIPTOR`
%
%  are loaded.
%  Stores the results in csv files in:
%
%      `<HBROOT>/matlab/results/default/DESCRIPTOR/retrieval.csv`
%
%  If the scores file already exists, skips the computation. Use
%  `'override', true` to change this behaviour.
%
%  For reproducing the article results run with:
%      RETRIEVAL(DESCRIPTOR, 'num_neg', inf, ...)
%  Otherwise computes the scores only with the top-2000 negative descriptors.
%  This is to reduce the memory demands.
%
%  Additionally accepts the following 'OptionName', OptionValue arguments:
%
%  'scoresroot' :: '<HBROOT>/matlab/results/default/'
%     Change for a different target path for scores.
%   
%  'taskpath' :: '<HBROOT>/tasks'
%     Location of te tasks files.
%
%  'geom_noise' :: {'easy', 'hard', 'tough'}
%    Limit the geometry noise computed.
%
%  'split' :: {'a', 'b', 'c', 'illum', 'view', 'full'}
%    Limit the splits on which the scores are computed.
%
%  'override' :: false
%     If true, do override existing score file.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if ischar(des), [des, varargin] = desc.memdesc(des, varargin{:}); end;
opts.scoresroot = fullfile(hb_path, 'matlab', 'scores', 'default');
[opts, varargin] = vl_argparse(opts, varargin);
opts.taskspath = fullfile(hb_path, 'tasks');
opts.scorespath = fullfile(opts.scoresroot, des.name, 'retrieval.csv');
opts.split = {'a', 'b', 'c', 'illum', 'view', 'full'};
opts.geom_noise = {'easy', 'hard', 'tough'};
opts.methods = struct('name', {'removequery'}, 'args', {{}});
opts.override = false;
opts.verbose = false;
[opts, varargin] = vl_argparse(opts, varargin);

if opts.verbose, display(opts); end;
if ~iscell(opts.split), opts.split = {opts.split}; end;
if ~iscell(opts.geom_noise), opts.geom_noise  = {opts.geom_noise}; end;
vl_xmkdir(fileparts(opts.scorespath));
if ~opts.override && exist(opts.scorespath, 'file')
  res = readtable(opts.scorespath);
  fprintf('Results loaded from %s.\n', opts.scorespath);
  return;
end;

get_queries = @(split) fullfile(opts.taskspath, ...
  sprintf('retr_queries_split-%s.csv', split));
get_distractors = @(split) fullfile(opts.taskspath, ...
  sprintf('retr_distractors_split-%s.csv', split));

numtasks = numel(opts.split)*numel(opts.geom_noise)*numel(opts.methods);
status = utls.textprogressbar(numtasks, 'updatestep', 1, ...
  'startmsg', sprintf('Evaluating "retrieval" for %s', des.name));
stepi = 1;
res = cell(numtasks, 1);
for gni = 1:numel(opts.geom_noise)
  gnoise = opts.geom_noise{gni};
  for si = 1:numel(opts.split)
    split = opts.split{si};
    queries = get_queries(split);
    distractors = get_distractors(split);
    for mi = 1:numel(opts.methods)
      method = opts.methods(mi);
      res_s = bench.retrieval.eval(des, gnoise, queries, distractors, ...
        method.args{:}, varargin{:});
      res{stepi} = struct(...
        'descriptor', des.name, 'split', split, ...
        'geom_noise', gnoise, 'method', method.name, ...
        'mauc', mean(res_s.auc), 'map', mean(res_s.ap));
      status(stepi); stepi = stepi+1;
    end
  end
end
res = struct2table(cell2mat(res), 'AsArray', true);
writetable(res, opts.scorespath);

fprintf('\n');
