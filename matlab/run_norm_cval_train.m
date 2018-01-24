% Test roughly different versions of normalisations on a single split
hb_setup;
descs = {'resize', 'sift', 'binboost'  'brief'  'deepdesc', ...
  'meanstd'  'orb'  ...
  'rootsift'  'siam'  'siam2stream',  'tfeat-margin'  ...
  'tfeat-margin-star'  'tfeat-ratio'  'tfeat-ratio-star', ...
  'kde', 'mkd', 'wlrn', ...
  'HardNetLib', 'HardNetLib+', 'tfeat-n-lib', ...
  'tfeat-n-train-a', 'tfeat-n-train-b', 'tfeat-n-train-c'};
splitsDb = utls.splitsdb('addValSplits', {'a', 'b', 'c'});
exp_args = { 'split', 'full',...
  'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_norm_cval_small'), ...
  'geom_noise', {'easy', 'hard', 'tough'}, 'verbose', true, 'normSplitsDb', splitsDb};
norm_splits = {'a', 'b', 'c'};

%descs = {'meanstd'}; exp_args = [exp_args, {'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_norm_cval_subset')}];
%descs = {'wlrn'}

methods = {};
% Power law / l2norm
methods{end+1} = {'pl', 1, 'l2norm', false, 'whiten', '', 'clipeigen', 0}; % No normalisation
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
  for nmi = 1:numel(methods)
    for spi = 1:numel(norm_splits)
      split = norm_splits{spi};
      if contains(descs{di}, '-train-')
        det_split = descs{di}(end);
        % Evaluate detector only on their splits
        if ~strcmp(det_split, split), continue; end
      end
      args{end+1} = [{'all', descname, 'norm', 'true'}, exp_args, ...
        methods{nmi}, {'norm_split', split, 'split', 'full', ...
        'filterSeq', splitsDb.(split).val, 'addProps', {'valsplit', split}}];
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
