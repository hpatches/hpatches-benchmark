hb_setup();

res = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_norm_small'));

%%

categories = cellfun(@(a) a(1), res.matching.sequence, 'Uni', false);
res.matching.category = categories;
% Compute the matching scores averages
res.matching_g = varfun(@mean, res.matching, ...
  'GroupingVariables', {'descriptor', 'geom_noise', 'category'}, ...
  'InputVariables', 'ap');

%% Separate the normalisation type and split out of descriptor name

res.verification_e = rproc.postproc_norm(res.verification);
res.matching_ge = rproc.postproc_norm(res.matching_g);
res.retrieval_e = rproc.postproc_norm(res.retrieval);


%% Compute average over the norm splits
res.verification_en = varfun(@mean, res.verification_e, ...
  'GroupingVariables', {'descriptor', 'split', 'negs', 'geom_noise', 'method', 'norm_type'}, ...
  'InputVariables', 'pr_ap');


res.matching_gen = varfun(@mean, res.matching_ge, ...
  'GroupingVariables', {'descriptor', 'geom_noise', 'category', 'norm_type'}, ...
  'InputVariables', 'mean_ap');

res.retrieval_en = varfun(@mean, res.retrieval_e, ...
  'GroupingVariables', {'descriptor', 'split', 'geom_noise', 'method', 'norm_type'}, ...
  'InputVariables', 'map');

%% Pick the best normalisation per descriptor
% Preprocess the results

ver_ = res.verification_en;
ver_(~cellfun(@(a) strcmp(a, 'b'), ver_.split), :) = [];
ver_(~cellfun(@(a) strcmp(a, 'imbalanced'), ver_.method), :) = [];

ver_ = varfun(@mean, ver_, ...
  'GroupingVariables', {'descriptor', 'split', 'norm_type'}, ...
  'InputVariables', 'mean_pr_ap');
ver_.split = []; ver_.GroupCount = [];
ver_ = unstack(ver_, 'mean_mean_pr_ap', 'norm_type');
ver_.Properties.RowNames = ver_.descriptor;
ver_.descriptor = [];

match_ = res.matching_gen;
match_.GroupCount = [];
match_ = varfun(@mean, match_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'mean_mean_ap');
match_.GroupCount = [];
match_ = unstack(match_, 'mean_mean_mean_ap', 'norm_type');
match_.Properties.RowNames = match_.descriptor;
match_.descriptor = [];

retr_ = res.retrieval_en;
retr_.GroupCount = [];
retr_(cellfun(@(a) strcmp(a, 'keepquery'), retr_.method), :) = [];
retr_ = varfun(@mean, retr_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'mean_map');
retr_.GroupCount = [];
retr_ = unstack(retr_, 'mean_mean_map', 'norm_type');
retr_.Properties.RowNames = retr_.descriptor;
retr_.descriptor = [];

%%
ver_best = max(max(ver_{:, :}));
match_best = max(max(match_{:, :}));
retr_best = max(max(retr_{:, :}));

% Weight the scores relatively to the best score
total_score = ver_;
total_score{:,:} = (ver_{:,:} ./ ver_best + match_{:,:} ./ match_best + retr_{:,:} ./ retr_best) ./ 3;

[~, best_norm] = max(total_score{:,:}, [], 2);
best_norm_name = total_score.Properties.VariableNames(best_norm)';

best_norm = struct('descriptor', total_score.Properties.RowNames, ...
  'normstr', best_norm_name);
best_norm = struct2table(best_norm, 'asArray', true);
%%
writetable(best_norm, fullfile(hb_path, 'matlab', 'data', 'best_normalizations.csv'));
