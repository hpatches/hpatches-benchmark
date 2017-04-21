% Test roughly different versions of normalisations on a single split

descs = {'resize', 'sift', 'binboost'  'brief'  'deepdesc', ...
  'meanstd'  'orb'  ...
  'rootsift'  'siam'  'siam2stream',  'tfeat-margin'  ...
  'tfeat-margin-star'  'tfeat-ratio'  'tfeat-ratio-star'};
exp_args = {'split', 'b', ...
  'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_norm_small'), ...
  'geom_noise', {'easy', 'hard', 'tough'}, 'verbose', true};
norm_splits = {'a'};

methods = {};
% Power law / l2norm
methods{end+1} = {'pl', 0.5, 'l2norm', false, 'whiten', '', 'clipeigen', 0};
methods{end+1} = {'pl', 1.0, 'l2norm', true,  'whiten', '', 'clipeigen', 0};
methods{end+1} = {'pl', 0.5, 'l2norm', true,  'whiten', '', 'clipeigen', 0};

% PCA / ZCA
clipeigens = [0, 0.05, 0.075 0.1, 0.15, 0.2, 0.25, 0.3, 0.4];
for ci = 1:numel(clipeigens)
  ld = clipeigens(ci);
  methods{end+1} = {'pl', 0.5, 'l2norm', false, 'whiten', 'pca', 'clipeigen', ld};
  methods{end+1} = {'pl', 0.5, 'l2norm', false, 'whiten', 'zca', 'clipeigen', ld};
  
  methods{end+1} = {'pl', 0.5, 'l2norm', true, 'whiten', 'pca', 'clipeigen', ld};
  methods{end+1} = {'pl', 0.5, 'l2norm', true, 'whiten', 'zca', 'clipeigen', ld};
end

args_list = {};
args = {};
for di = 1:numel(descs)
  descname = descs{di};
  args{end+1} = [{'all', descname}, exp_args];
  for nmi = 1:numel(methods)
    for spi = 1:numel(norm_splits)
      split = norm_splits{spi};
      args{end+1} = [{'all', descname, 'norm', 'true'}, exp_args, ...
        methods{nmi}, {'norm_split', split}];
    end
  end
end
fprintf('%d tasks.\n', numel(args));
%%

sel = utls.parallelise(1:numel(args));
for ai = 1:size(sel, 1)
  hb(args{sel(ai)}{:});
end
%%
