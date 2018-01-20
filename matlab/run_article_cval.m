% Recompute all scores for all descriptors.
% Requires approximately at least 64GB RAM, unless `num_neg` is decreased.

descs = {'resize', 'sift', 'binboost'  'brief'  'deepdesc', ...
  'meanstd'  'orb'  ...
  'rootsift'  'siam'  'siam2stream',  'tfeat-margin'  ...
  'tfeat-margin-star'  'tfeat-ratio'  'tfeat-ratio-star', ...
  'kde', 'mkd', 'wrln'};
descs = {'meanstd'};
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
  args{end+1} = [descs(di), global_args, {'split', splits}];
  % Add best norm descriptor, diff norm per split
  for spi = 1:numel(splits)
    desc_name = [descs{di}, '-train-', splits{spi}];
    args{end+1} = [{descs{di}, 'norm', true, 'norm_split', splits{spi}, ...
      'normstring', norms{desc_name, 'normstr'}{1}}, ...
      'split', splits{spi}, global_args];
  end
end
fprintf('%d tasks.\n', numel(args));

%%
sel = utls.parallelise(1:numel(args));
for ai = 1:size(sel, 1)
  hb('all', args{sel(ai)}{:});
end
