% Recompute all scores for all descriptors.
% Requires approximately at least 64GB RAM, unless `num_neg` is decreased.

descs = {'resize', 'sift', 'binboost'  'brief'  'deepdesc', ...
  'meanstd'  'orb'  ...
  'rootsift'  'siam'  'siam2stream',  'tfeat-margin'  ...
  'tfeat-margin-star'  'tfeat-ratio'  'tfeat-ratio-star', ...
  'kde', 'mkd', 'wlrn', 'tfeat-n-lib', 'l2net', 'tnet', ...
  'HardNetLib', 'HardNetLib+', ...
  'tfeat-n-train-a', 'tfeat-n-train-b', 'tfeat-n-train-c', ...
  'hpa', 'hpb', 'hpc', 'hp_il', 'hp_view'};
nonorm = {'hpa', 'hpb', 'hpc', 'hp_il', 'hp_view'};
%descs = {'meanstd'};
global_args = {'num_neg', inf, 'numtype', 'double', ...
  'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_all_cval')};
splits = {'a', 'b', 'c'};
%%
norms_path = fullfile(hb_path, 'matlab', 'data', 'best_normalizations_cval.csv');
norms = readtable(norms_path, 'delimiter', ',');
norms.Properties.RowNames = norms.descriptor;
%%
args = {};
for di = 1:numel(descs)
  % Add original descriptor
  if contains(descs{di}, '-train-')
    % Those are already defined three times
    args{end+1} = [descs(di), global_args, {'split', descs{di}(end)}];
  else
    args{end+1} = [descs(di), global_args, {'split', splits}];
  end
  if ismember(descs{di}, nonorm)
    fprintf('Skipping norm for %s\n', descs{di});
    continue;
  end
  % Add best norm descriptor, diff norm per split
  for spi = 1:numel(splits)
    if contains(descs{di}, '-train-')
      desc_name = descs{di};
      det_split = descs{di}(end);
      if ~strcmp(det_split, splits{spi}), continue; end
    else
      desc_name = [descs{di}, '-train-', splits{spi}];
    end
    args{end+1} = [{descs{di}, 'norm', true, 'norm_split', splits{spi}, ...
      'normstring', norms{desc_name, 'normstr'}{1}}, ...
      'split', splits{spi}, global_args];
  end
end
fprintf('%d tasks.\n', numel(args));

%%
sel = utls.parallelise(1:numel(args));
parfor ai = 1:size(sel, 1)
  hb('all', args{sel(ai)}{:});
end
