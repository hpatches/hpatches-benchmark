function res = matching( des, varargin )
%MATCHING Run the image matching task
%  RES = MATCHING(DESCRIPTOR) Compute the results for descriptor
%  DESCRIPTOR. Descriptor can either be an object of desc.memdesc or a
%  string, in which case a descriptor from
%
%     `<HBROOT>/data/descriptors/DESCRIPTOR`
%
%  are loaded.
%  Stores the results in csv files in:
%
%      `<HBROOT>/matlab/results/default/DESCRIPTOR/matching.csv`
%
%  If the scores file already exists, skips the computation. Use
%  `'override', true` to change this behaviour.
%
%  Additionally accepts the following 'OptionName', OptionValue arguments:
%
%  'scoresroot' :: '<HBROOT>/matlab/results/default/'
%     Change for a different target path for scores.
%
%  'sequences' :: all of the present for the descriptor
%     Limit the sequences for which the scores are computed (cell array of
%     strings).
%
%  'geom_noise' :: {'easy', 'hard', 'tough'}
%     Limit the geometry noise computed.
%
%  'impairs' :: [1 2; 1 3; 1 4; 1 5; 1 6]
%     Change the image pairs for which the scores are computed.
%
%  'override' :: false
%     Do not overwrite existing score files.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if ischar(des), [des, varargin] = desc.memdesc(des, varargin{:}); end
opts.scoresroot = fullfile(hb_path, 'matlab', 'scores', 'default');
[opts, varargin] = vl_argparse(opts, varargin);
opts.scorespath = fullfile(opts.scoresroot, des.name, 'matching.csv');
opts.split = {'a', 'b', 'c', 'illum', 'view', 'full'};
opts.geom_noise = {'easy', 'hard', 'tough'};
opts.impairs = [1 2; 1 3; 1 4; 1 5; 1 6];
opts.filterSeq = {};
opts.addProps = {};
opts.override = false;
opts.loadOnly = false;
opts.verbose = false;
[opts, ~] = vl_argparse(opts, varargin);

if opts.verbose, display(opts); end
if ~iscell(opts.geom_noise), opts.geom_noise  = {opts.geom_noise}; end
if ~iscell(opts.split), opts.split  = {opts.split}; end
vl_xmkdir(fileparts(opts.scorespath));
if ~opts.override && exist(opts.scorespath, 'file')
  res = readtable(opts.scorespath);
  fprintf('Results loaded from %s.\n', opts.scorespath);
  return;
elseif opts.loadOnly
  res = [];
  return;
end

splits_data = utls.parse_json(fullfile(hb_path, 'matlab', 'data', 'splits.json'));
sequences = cell(1, numel(opts.split));
for spi = 1:numel(opts.split)
  split = opts.split{spi};
  sequences{spi} = splits_data.(split).test;
  if ~isempty(opts.filterSeq)
    validSeq = ismember(sequences{spi}, opts.filterSeq);
    sequences{spi}(~validSeq) = [];
  end
end
allseq = unique(horzcat(sequences{:}));

numtasks = numel(allseq) * numel(opts.geom_noise) * size(opts.impairs, 1);
status = utls.textprogressbar(numtasks, 'updatestep', 1, ...
  'startmsg', sprintf('Evaluating "matching" for %s', des.name));
stepi = 1;
res = {};
for gni = 1:numel(opts.geom_noise)
  geom_noise = opts.geom_noise{gni};
  res_s = cell(numel(allseq{spi}), size(opts.impairs, 1));
  % Compute results for all sequences, removing duplicates
  for seqi = 1:numel(allseq)
    sequence = allseq{seqi};
    for pi = 1:size(opts.impairs, 1)
      pair = opts.impairs(pi, :);
      descA = des.getimdescs(des, sequence, geom_noise, pair(1));
      descB = des.getimdescs(des, sequence, geom_noise, pair(2));
      res_s{seqi, pi} = bench.matching.eval(descA, descB);
      status(stepi); stepi = stepi+1;
    end
  end
  % Distribute the results to the final structure honoring the splits
  for spi = 1:numel(opts.split)
    split = opts.split{spi};
    splitseq = sequences{spi};
    for seqi = 1:numel(splitseq)
      sequence = splitseq{seqi};
      [~, seq_id] = ismember(sequence, allseq);
      for pi = 1:size(opts.impairs, 1)
        r = res_s{seq_id, pi};
        pair = opts.impairs(pi, :);
        res{end+1} = struct(...
          'descriptor', des.name, 'split', split, 'sequence', sequence, ...
          'geom_noise', geom_noise, 'ima', pair(1)-1, 'imb', pair(2)-1, ...
          'ap', r.ap, 'auc', r.auc, 'sr', r.sr, opts.addProps{:});
        if ~isempty(opts.filterSeq)
          res{end}.filterSeq = strjoin(opts.filterSeq, ':');
        end
      end
    end
  end
end
res = struct2table(cell2mat(res), 'AsArray', true);
writetable(res, opts.scorespath);
fprintf('\n');
