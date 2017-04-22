% Recompute all scores for all descriptors.
% Requires approximately at least 64GB RAM, unless `num_neg` is decreased.

descs = {'sift', 'binboost'  'brief'  'deepdesc'  'meanstd'  'orb'  'resize'  ...
  'rootsift'  'siam'  'siam2stream',  'tfeat-margin'  ...
  'tfeat-margin-star'  'tfeat-ratio'  'tfeat-ratio-star'};
global_args = {'split', 'full', 'num_neg', inf, 'numtype', 'double', ...
  'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_all')};

norm_splits = {'c'};
norms_path = fullfile(hb_path, 'matlab', 'data', 'best_normalizations.csv');
norms = readtable(norms_path, 'delimiter', ',');
norms.Properties.RowNames = norms.descriptor;

args = {};
for di = 1:numel(descs)
  args{end+1} = [descs(di), global_args];
  for ni = 1:numel(norm_splits)
    args{end+1} = [{descs{di}, 'norm', true, 'norm_split', norm_splits{ni}, ...
      'normstring', norms{descs{di}, 'normstr'}{1}}, global_args];
  end
end
fprintf('%d tasks.\n', numel(args));

%%
sel = utls.parallelise(1:numel(args));
for ai = 1:size(sel, 1)
  hb('all', args{sel(ai)}{:});
end