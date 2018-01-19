% Recompute the best normalisation for all descriptors.

hb_setup();

res = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_norm_cval_subset'));

%%

res = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_norm_cval_small'));

%%

categories = cellfun(@(a) a(1), res.matching.sequence, 'Uni', false);
res.matching.category = categories;
% Compute the matching scores averages
res.matching_g = varfun(@mean, res.matching, ...
  'GroupingVariables', {'descriptor', 'geom_noise', 'category'}, ...
  'InputVariables', 'ap');

%% Separate the normalisation type and split out of descriptor name

res.verification_en = rproc.postproc_norm(res.verification, 'embedNormSplit', true);
res.matching_gen = rproc.postproc_norm(res.matching_g, 'embedNormSplit', true);
res.retrieval_en = rproc.postproc_norm(res.retrieval, 'embedNormSplit', true);

%% Pick the best normalisation per descriptor
% Preprocess the results

ver_ = res.verification_en;
ver_(~cellfun(@(a) strcmp(a, 'imbalanced'), ver_.method), :) = [];

ver_ = varfun(@mean, ver_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'pr_ap');
ver_ = unstack(ver_, 'mean_pr_ap', 'norm_type');
ver_.Properties.RowNames = ver_.descriptor;
ver_.descriptor = [];
ver_.GroupCount = [];

match_ = res.matching_gen;
match_ = varfun(@mean, match_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'mean_ap');
match_.GroupCount = [];
match_ = unstack(match_, 'mean_mean_ap', 'norm_type');
match_.Properties.RowNames = match_.descriptor;
match_.descriptor = [];

retr_ = res.retrieval_en;
retr_(cellfun(@(a) strcmp(a, 'keepquery'), retr_.method), :) = [];
retr_ = varfun(@mean, retr_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'map');
retr_.GroupCount = [];
retr_ = unstack(retr_, 'mean_map', 'norm_type');
retr_.Properties.RowNames = retr_.descriptor;
retr_.descriptor = [];

%%
ver_best = max(ver_{:, :}, [], 2);
match_best = max(match_{:, :}, [], 2);
retr_best = max(retr_{:, :}, [], 2);

% Weight the scores relatively to the best score
total_score = ver_; % Just pre-alloc
total_score{:,:} = (bsxfun(@times, ver_{:,:}, 1./ver_best) + bsxfun(@times, match_{:,:} , 1./ match_best) + bsxfun(@times, retr_{:,:},  1./ retr_best)) ./ 3;

[~, best_norm] = max(total_score{:,:}, [], 2);
best_norm_name = total_score.Properties.VariableNames(best_norm)';

best_norm = struct('descriptor', total_score.Properties.RowNames, ...
  'normstr', best_norm_name);
best_norm = struct2table(best_norm, 'asArray', true);
%%
writetable(best_norm, fullfile(hb_path, 'matlab', 'data', 'best_normalizations_cval.csv'));
