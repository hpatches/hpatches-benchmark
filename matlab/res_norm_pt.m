% Recompute the best normalisation for all descriptors.

hb_setup();

%res = rproc.read('scoresroot', ...
%  fullfile(hb_path, 'matlab', 'scores', 'scores_norm_cval_subset'));

%%

res_pt = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_norm_pt_small'), 'dataset', 'pt');

%% Separate the normalisation type and split out of descriptor name

res_pt.verification_e = rproc.postproc_norm(res_pt.verification_pt, 'embedNormSplit', true);
% remove where nsplit is the same as eval split
invalid = strcmp(res_pt.verification_e.norm_split, res_pt.verification_e.sequence);
res_pt.verification_e(invalid, :) = [];

%% Pick the best normalisation per descriptor
% Preprocess the results

ver_ = res_pt.verification_e;

ver_ = varfun(@mean, ver_, ...
  'GroupingVariables', {'descriptor', 'norm_type'}, ...
  'InputVariables', 'pr_ap');
ver_ = unstack(ver_, 'mean_pr_ap', 'norm_type');
ver_.Properties.RowNames = ver_.descriptor;
ver_.descriptor = [];
ver_.GroupCount = [];

%%
ver_best = max(ver_{:, :}, [], 2);

% Weight the scores relatively to the best score
total_score = ver_; % Just pre-alloc
total_score{:,:} = bsxfun(@times, ver_{:,:}, 1./ver_best);

[~, best_norm] = max(total_score{:,:}, [], 2);
best_norm_name = total_score.Properties.VariableNames(best_norm)';

best_norm = struct('descriptor', total_score.Properties.RowNames, ...
  'normstr', best_norm_name);
best_norm = struct2table(best_norm, 'asArray', true);
%%
writetable(best_norm, fullfile(hb_path, 'matlab', 'data', 'best_normalizations_pt.csv'));
