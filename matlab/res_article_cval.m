hb_setup();

res = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_all_cval'));

norms_path = fullfile(hb_path, 'matlab', 'data', 'best_normalizations_cval.csv');
norms = readtable(norms_path, 'delimiter', ',');
norms.Properties.RowNames = norms.descriptor;

%%
outpath = fullfile(hb_path, 'matlab', 'results', 'article_cval');
vl_xmkdir(outpath);
addpath(fullfile(hb_path, '../matlab2tikz/src/'));

sequences = utls.listdirs(fullfile(hb_path, 'data', 'hpatches-release'));
illum_seq = cellfun(@(a) strcmp(a(1:2), 'i_'), sequences);
viewp_seq = cellfun(@(a) strcmp(a(1:2), 'v_'), sequences);

categories = cellfun(@(a) a(1), res.matching.sequence, 'Uni', false);
res.matching.category = categories;
% Compute the matching scores averages
res.matching_g = varfun(@mean, res.matching, ...
  'GroupingVariables', {'descriptor', 'geom_noise', 'category', 'split'}, ...
  'InputVariables', 'ap');

%% Separate the normalisation type and split out of descriptor name

res.verification_e = rproc.postproc_norm(res.verification, 'renameNorm', true);
res.matching_ge = rproc.postproc_norm(res.matching_g, 'renameNorm', true);
res.retrieval_e = rproc.postproc_norm(res.retrieval, 'renameNorm', true);


%% Compute average over the norm splits

res.verification_en = varfun(@mean, res.verification_e, ...
  'GroupingVariables', {'descriptor', 'split', 'negs', 'geom_noise', 'method', 'norm_type'}, ...
  'InputVariables', 'pr_ap');

res.matching_gen = varfun(@mean, res.matching_ge, ...
  'GroupingVariables', {'descriptor', 'split', 'geom_noise', 'category', 'norm_type'}, ...
  'InputVariables', 'mean_ap');

res.retrieval_en = varfun(@mean, res.retrieval_e, ...
  'GroupingVariables', {'descriptor', 'split', 'geom_noise', 'method', 'norm_type'}, ...
  'InputVariables', 'mauc');

%%
in_c = @(a, b) max(min(a.*b, 1), 0);

cip = 1;
colors = struct();
colors.resize = in_c(utls.rgb('SlateGray'), cip);
colors.meanstd = in_c(utls.rgb('Silver'), cip);

colors.sift = in_c(utls.rgb('SeaGreen'), cip);
colors.rootsift = in_c(utls.rgb('Olive'), cip);
colors.kde = in_c(utls.rgb('Teal'), cip);
colors.mkd = in_c(utls.rgb('YellowGreen'), cip);

colors.brief = in_c(utls.rgb('DarkCyan'), cip);
colors.binboost = in_c(utls.rgb('SteelBlue'), cip);
colors.orb = in_c(utls.rgb('SkyBlue'), cip);

colors.siam = in_c(utls.rgb('Salmon'), cip);
colors.siam2stream = in_c(utls.rgb('Peru'), cip);
colors.deepdesc = in_c(utls.rgb('SaddleBrown'), cip);
colors.tfmargin = in_c(utls.rgb('Goldenrod'), cip);
colors.tfratio = in_c(utls.rgb('Chocolate'), cip);
colors.tfeatnlib = in_c(utls.rgb('Gold'), cip);

colors.tnet = in_c(utls.rgb('Crimson'), cip);
colors.l2net = in_c(utls.rgb('IndianRed'), cip);
%colors.hardnetlib = in_c(utls.rgb('Tan'), cip);
colors.hardnetlibp = in_c(utls.rgb('Red'), cip);



bnames = {};  ls = {'EdgeColor', [1, 1, 1] * 0.2};
bnames{end+1} = struct('name', 'meanstd', 'printname', '\meanstd', 'texname', 'MStd', ...
  'color', colors.resize, 'barargs', {ls}, ...
  'dim', 2, 'isbin', false, 'psize', 65, 'pps', 67000, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'resize', 'printname', '\resize', 'texname', 'Resz', ...
  'color', colors.resize, 'barargs', {ls}, ...
  'dim', 36, 'isbin', false, 'psize', 65, 'pps', 3000, 'gpu', false, 'ppsgpu', nan);

bnames{end+1} = struct('name', 'sift', 'printname', '\sift', 'texname', 'SIFT', ...
  'color', colors.sift, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 65, 'pps', 2251, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'rootsift', 'printname', '\rootsift', 'texname', 'RSIFT', ...
  'color', colors.rootsift, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 65, 'pps', 2157, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'kde', 'printname', '\kde', 'texname', 'KDE', ...
  'color', colors.kde, 'barargs', {ls}, ...
  'dim', 147, 'isbin', false, 'psize', 65, 'pps', 286, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'mkd', 'printname', '\mkd', 'texname', 'MKD', ...
  'color', colors.mkd, 'barargs', {ls}, ...
  'dim', 238, 'isbin', false, 'psize', 65, 'pps', 63, 'gpu', false, 'ppsgpu', nan);

bnames{end+1} = struct('name', 'brief', 'printname', '\brief', 'texname', 'BRIEF', ...
  'color', colors.brief, 'barargs', {ls},...
  'dim', 256, 'isbin', true, 'psize', 32, 'pps', 333000, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'binboost', 'printname', '\binboost', 'texname', 'BBoost', ...
  'color', colors.binboost, 'barargs', {ls},...
  'dim', 256, 'isbin', true, 'psize', 32, 'pps', 2000, 'gpu', false, 'ppsgpu', nan);
bnames{end+1} = struct('name', 'orb', 'printname', '\orb', 'texname', 'ORB', ...
  'color', colors.orb, 'barargs', {ls}, ...
  'dim', 256, 'isbin', true, 'psize', 32, 'pps', 333000, 'gpu', false, 'ppsgpu', nan);

bnames{end+1} = struct('name', 'siam', 'printname', '\dcsiam', 'texname', 'DC-S', ...
  'color', colors.siam, 'barargs', {ls}, ...
  'dim', 256, 'isbin', false, 'psize', 64, 'pps', 300, 'gpu', true, 'ppsgpu', 10000);
bnames{end+1} = struct('name', 'siam2stream', 'printname', '\dcsiamts', 'texname', 'DC-S2S', ...
  'color', colors.siam2stream, 'barargs', {ls},...
    'dim', 512, 'isbin', false, 'psize', 64, 'pps', 200, 'gpu', true, 'ppsgpu', 5000);
bnames{end+1} = struct('name', 'deepdesc', 'printname', '\deepdesc', 'texname', 'DDesc', ...
  'color', colors.deepdesc, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 64, 'pps', 100, 'gpu', true, 'ppsgpu', 2300);
%bnames{end+1} = struct('name', 'tfeat-margin', 'printname', 'tfeat-margin');
bnames{end+1} = struct('name', 'tfeat-n-lib', 'printname', '\tfn', 'texname', 'TF', ...
  'color', colors.tfeatnlib, 'barargs', {ls}, ...
  'dim', 512, 'isbin', false, 'psize', 32, 'pps', 600, 'gpu', true, 'ppsgpu', 83000);
%bnames{end+1} = struct('name', 'tfeat-ratio', 'printname', 'tf-ratio');
bnames{end+1} = struct('name', 'tfeat-ratio-star', 'printname', '\tfratio', 'texname', 'TF-R', ...
  'color', colors.tfratio, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 32, 'pps', 600, 'gpu', true, 'ppsgpu', 83000);
bnames{end+1} = struct('name', 'tfeat-margin-star', 'printname', '\tfmargin', 'texname', 'TF-M', ...
  'color', colors.tfmargin, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 32, 'pps', 600, 'gpu', true, 'ppsgpu', 83000);
%bnames{end+1} = struct('name', 'wlrn', 'printname',  '\wlrn', 'texname', 'WLRN', ...
%  'color', in_c(utls.rgb('Goldenrod'), cip), 'barargs', {ls}, ...
%  'dim', 128, 'isbin', false, 'psize', nan, 'pps', nan, 'gpu', true);
bnames{end+1} = struct('name', 'tnet', 'printname', '\tnet', 'texname', 'TNet', ...
  'color', colors.tnet, 'barargs', {ls}, ...
  'dim', 256, 'isbin', false, 'psize', 64, 'pps', 388, 'gpu', true, 'ppsgpu', 83000);
bnames{end+1} = struct('name', 'l2net', 'printname', '\ltnet', 'texname', 'L2-Net', ...
  'color', colors.l2net, 'barargs', {ls}, ...
  'dim', 256, 'isbin', false, 'psize', 64, 'pps', 79, 'gpu', true, 'ppsgpu', 63284);
%bnames{end+1} = struct('name', 'HardNetLib', 'printname', '\hardnet', 'texname', 'HardNet', ...
%  'color', colors.hardnetlib, 'barargs', {ls}, ...
%  'dim', 128, 'isbin', false, 'psize', nan, 'pps', nan, 'gpu', true);
bnames{end+1} = struct('name', 'HardNetLib+', 'printname', '\hardnetplus', 'texname', 'HNet', ...
  'color', colors.hardnetlibp, 'barargs', {ls}, ...
  'dim', 128, 'isbin', false, 'psize', 32, 'pps', 714, 'gpu', true, 'ppsgpu', 3125);

bnames = cell2mat(bnames);

baselines = struct('name', {bnames.name}, 'printname', {bnames.printname}, ...
  'color', {bnames.color}, ...
  'bararg', {bnames.barargs});

baselines_chance = struct('name', 'chance', 'printname', '\chance', ...
  'color', in_c(utls.rgb('White'), cip), 'bararg', {ls});
clear normname;

bnames_pca = {}; cip = 1; ls = {'EdgeColor', [1, 1, 1] * 0, 'LineStyle', '--'};
%bnames_pca{end+1} = struct('name', 'meanstd_norm', 'printname', '+meanstd');
%bnames_pca{end+1} = struct('name', 'resize_norm', 'printname', '+resize');
bnames_pca{end+1} = struct('name', 'sift-norm', 'printname', '\psift', 'texname', '+SIFT', ...
  'color', colors.sift, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'rootsift-norm', 'printname', '\prootsift', 'texname', '+RSIFT', ...
  'color', colors.rootsift, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'kde-norm', 'printname', '\pkde', 'texname', '+KDE', ...
  'color', colors.kde, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'mkd-norm', 'printname', '\pmkd', 'texname', '+MKD', ...
  'color', colors.mkd, 'barargs', {ls});


%bnames_pca{end+1} = struct('name', 'siam-norm', 'printname', '\pdcsiam', 'texname', '+DC-S', ...
%  'color', in_c(utls.rgb('Salmon'), cip), 'barargs',{ls});
bnames_pca{end+1} = struct('name', 'siam-norm', ...
  'printname', '\pdcsiam', 'texname', '+DC-S', ...
  'color', colors.siam, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'siam2stream-norm', ...
  'printname', '\pdcsiamts', 'texname', '+DC-2S', ...
  'color', colors.siam, 'barargs', {ls});
%bnames_pca{end+1} = struct('name', 'siam2stream_norm', 'printname', '+dc-siam2stream');
bnames_pca{end+1} = struct('name', 'deepdesc-norm', ...
  'printname', '\pdeepdesc', 'texname', '+DDesc', ...
  'color', colors.deepdesc, 'barargs', {ls});
%bnames_pca{end+1} = struct('name', 'tfeat-margin_norm', 'printname', '+tf-margin');
bnames_pca{end+1} = struct('name', 'tfeat-n-lib-norm', ...
  'printname', '\ptfn', 'texname', '+TF', ...
  'color', colors.tfeatnlib, 'barargs', {ls});
%bnames_pca{end+1} = struct('name', 'tfeat-ratio_norm', 'printname', '+tf-ratio');
%bnames_pca{end+1} = struct('name', 'tfeat-ratio-star-norm', 'printname', '\ptfratio', 'texname', '+TF-R', ...
%  'color', in_c(utls.rgb('Chocolate'), cip), 'barargs', {ls});
%bnames_pca{end+1} = struct('name', 'wlrn-norm', 'printname', '\pwlrn', 'texname', '+WLRN', ...
%  'color', in_c(utls.rgb('Goldenrod'), cip), 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'tnet-norm', 'printname', '\ptnet', 'texname', '+TNet', ...
  'color', colors.tnet, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'l2net-norm', 'printname', '\pltnet', 'texname', '+L2-Net', ...
  'color', colors.l2net, 'barargs', {ls});
%bnames_pca{end+1} = struct('name', 'HardNetLib-norm', 'printname', '\phardnet', 'texname', '+HardNet', ...
%  'color', colors.hardnetlib, 'barargs', {ls});
bnames_pca{end+1} = struct('name', 'HardNetLib+-norm', 'printname', '\phardnetplus', 'texname', '+HNet', ...
  'color', colors.hardnetlibp, 'barargs', {ls});
bnames_pca = cell2mat(bnames_pca);

baselines_pca = struct('name', {bnames_pca.name}, 'printname', {bnames_pca.printname}, ...
  'color', {bnames_pca.color}, ...
  'bararg', {bnames_pca.barargs});


%

trained = {}; cip = 1;
ls = {'EdgeColor', [1, 1, 1] * 0}; lsn = {'EdgeColor', [1, 1, 1] * 0, 'LineStyle', '--'};
%trained{end+1} = struct('name', 'wlrn', 'printname', '\wlrn', 'texname', 'WLRN', ...
%  'color', in_c(utls.rgb('Goldenrod'), cip), 'barargs', {ls});
trained{end+1} = struct('name', 'meanstd', 'printname', '\meanstd', 'texname', 'MStd', ...
  'color', colors.resize, 'barargs', {ls});
trained{end+1} = struct('name', 'sift', 'printname', '\sift', 'texname', 'SIFT', ...
  'color', colors.sift, 'barargs', {ls});


trained{end+1} = struct('name', 'tfeat-n-lib', 'printname', '\tfnlib', 'texname', 'TF', ...
  'color', colors.tfeatnlib, 'barargs', {ls});
trained{end+1} = struct('name', 'tfeat-n-train-a', ...
  'printname', '\tfna', 'texname', 'TFa', ...
  'color', in_c(colors.tfeatnlib, 0.8), 'barargs', {ls});
trained{end+1} = struct('name', 'tfeat-n-train-b', ...
  'printname', '\tfnb', 'texname', 'TFb', ...
  'color', in_c(colors.tfeatnlib, 0.7), 'barargs', {ls});
trained{end+1} = struct('name', 'tfeat-n-train-c', ...
  'printname', '\tfnc', 'texname', 'TFc', ...
  'color', in_c(colors.tfeatnlib, 0.5), 'barargs', {ls});



trained{end+1} = struct('name', 'HardNetLib+', 'printname', '\hardnetlib', 'texname', 'HardNetLib', ...
  'color', colors.hardnetlibp, 'barargs', {ls});

trained{end+1} = struct('name', 'hpa', ...
  'printname', '\hardneta', 'texname', 'HardNet+a', ...
  'color', in_c(colors.hardnetlibp, 0.8), 'barargs', {ls});
trained{end+1} = struct('name', 'hpb', ...
  'printname', '\hardnetb', 'texname', 'HardNet+b', ...
  'color', in_c(colors.hardnetlibp, 0.7), 'barargs', {ls});
trained{end+1} = struct('name', 'hpc', ...
  'printname', '\hardnetc', 'texname', 'HardNet+c', ...
  'color', in_c(colors.hardnetlibp, 0.5), 'barargs', {ls});
trained{end+1} = struct('name', 'hp_il', ...
  'printname', '\hardnetil', 'texname', 'HardNet+IL', ...
  'color', in_c(colors.hardnetlibp, 0.4), 'barargs', {{'LineStyle', '-.'}});
trained{end+1} = struct('name', 'hp_view', ...
  'printname', '\hardnetview', 'texname', 'HardNet+VIEW', ...
  'color', in_c(colors.hardnetlibp, 0.3), 'barargs', {{'LineStyle', ':'}});

trained = cell2mat(trained);

trained_s = struct('name', {trained.name}, 'printname', {trained.printname}, ...
  'color', {trained.color}, ...
  'bararg', {trained.barargs});
%
det_sets = {};

%det_sets{end+1}.dets = baselines;
%det_sets{end}.detnames = {bnames.printname};
%det_sets{end}.name = 'baselines';

%det_sets{end+1}.dets = baselines_pca;
%det_sets{end}.detnames = {bnames_pca.printname};
%det_sets{end}.name = 'baselines-pca';

det_sets{end+1}.dets = [baselines, baselines_pca];
det_sets{end}.detnames = [{bnames.printname}, {bnames_pca.printname}];
det_sets{end}.name = 'baselines-all';

%det_sets{end+1}.dets = trained_s;
%det_sets{end}.detnames = {trained_s.printname};
%det_sets{end}.name = 'trained';

%det_sets{end+1}.dets = [baselines, baselines_pca, baselines_chance];
%det_sets{end}.detnames = [{bnames.printname}, {bnames_pca.printname}, {baselines_chance.printname}];
%det_sets{end}.name = 'baselines-all-chance';

det_sets = cell2mat(det_sets);

task_clrs = [0,136,55; 94,60,153; 202,0,32] ./ 256;
%cl_tasks = {'full_diffseq_easy', 'full_diffseq_hard', 'full_diffseq_tough', 'full_sameseq_easy', 'full_sameseq_hard', 'full_sameseq_tough'};
marker_opts = {'LineWidth', 0.5, 'MarkerSize', 3};
mop = 1; mfp = 0.4;
cl_tasks = {...
  struct('filter', struct('negs', 'inter', 'geom_noise', 'easy', 'method', 'imbalanced'), 'style', ...
    {{'Marker', '*', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}}}), ... % full_diffseq_easy
  struct('filter', struct('negs', 'inter', 'geom_noise', 'hard', 'method', 'imbalanced'), 'style', ...
    {{'Marker', '*', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}}}), ... % full_diffseq_hard
  struct('filter', struct('negs', 'inter', 'geom_noise', 'tough', 'method', 'imbalanced'), 'style', ...
    {{'Marker', '*', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}}}), ... % full_diffseq_tough
  struct('filter', struct('negs', 'intra', 'geom_noise', 'easy', 'method', 'imbalanced'), 'style', ...
    {{'Marker', 'd', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}, 'MarkerSize', 1.5}}), ... % full_sameseq_easy
  struct('filter', struct('negs', 'intra', 'geom_noise', 'hard', 'method', 'imbalanced'), 'style', ...
    {{'Marker', 'd', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}, 'MarkerSize', 1.5}}), ... % full_sameseq_hard
  struct('filter', struct('negs', 'intra', 'geom_noise', 'tough', 'method', 'imbalanced'), 'style', ...
    {{'Marker', 'd', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}, 'MarkerSize', 1.5}})  ... % full_sameseq_tough
};
cl_tasks = cell2mat(cl_tasks);
marker_opts = {'LineWidth', 0.5, 'MarkerSize', 4};

%m_tasks = {...
%  'full_easy_illum', 'full_easy_viewpoint', 'full_hard_illum', 'full_hard_viewpoint', ...
%  'full_tough_illum', 'full_tough_viewpoint'};
m_tasks = {...
  struct('filter', struct('geom_noise', 'easy', 'category', 'i'), 'style', ...
    {{'Marker', 'x', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}}}), ... % full_easy_illum
  struct('filter', struct('geom_noise', 'easy', 'category', 'v'), 'style', ...
    {{'Marker', '<', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}}}), ... % full_easy_viewpoint
  struct('filter', struct('geom_noise', 'hard', 'category', 'i'), 'style', ...
    {{'Marker', 'x', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}}}), ... % full_hard_illum
  struct('filter', struct('geom_noise', 'hard', 'category', 'v'), 'style', ...
    {{'Marker', '<', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}}}), ... % full_hard_viewpoint
  struct('filter', struct('geom_noise', 'tough', 'category', 'i'), 'style', ...
    {{'Marker', 'x', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}}}), ... % full_tough_illum
  struct('filter', struct('geom_noise', 'tough', 'category', 'v'), 'style', ...
    {{'Marker', '<', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}}})  ... % full_tough_viewpoint
  };
m_tasks = cell2mat(m_tasks);

marker_opts = {'LineWidth', 0.5, 'MarkerSize', 3};
%r_tasks = {'full_easy_5s', 'full_easy_40s', ...
%  'full_hard_5s', 'full_hard_40s', 'full_tough_5s', 'full_tough_40s'};
method = 'removequery';
%method = 'keepquery';

r_tasks = {...
%  struct('filter', struct('split', 'small', 'geom_noise', 'easy', 'method', method), 'style', ...
%    {{'Marker', '.', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}, 'MarkerSize', 4}}), ... % full_easy_5s
  struct('filter', struct('geom_noise', 'easy', 'method', method), 'style', ...
    {{'Marker', 'o', 'Color', in_c(task_clrs(1, :), mop), 'MarkerFaceColor', in_c(task_clrs(1, :), mfp), marker_opts{:}, 'MarkerSize', 3}}), ... % full_easy_40s
%  struct('filter', struct('split', 'small', 'geom_noise', 'hard', 'method', method), 'style', ...
%    {{'Marker', '.', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}, 'MarkerSize', 4}}), ... % full_hard_5s
  struct('filter', struct('geom_noise', 'hard', 'method', method), 'style', ...
    {{'Marker', 'o', 'Color', in_c(task_clrs(2, :), mop), 'MarkerFaceColor', in_c(task_clrs(2, :), mfp), marker_opts{:}, 'MarkerSize', 3}}), ... % full_hard_40s
%  struct('filter', struct('split', 'small', 'geom_noise', 'tough', 'method', method), 'style', ...
%    {{'Marker', '.', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}, 'MarkerSize', 4}}), ... % full_tough_5s
  struct('filter', struct('geom_noise', 'tough', 'method', method), 'style', ...
    {{'Marker', 'o', 'Color', in_c(task_clrs(3, :), mop), 'MarkerFaceColor', in_c(task_clrs(3, :), mfp), marker_opts{:}, 'MarkerSize', 3}})  ... % full_tough_40s
  };

r_tasks = cell2mat(r_tasks);
%% Export the Figures

% Verification
ps = 2;
for dsi = 1:numel(det_sets)
  figure(11+dsi); clf;
  detnames = det_sets(dsi).detnames;
  rproc.bar_plot(res.verification_en, 'mean_pr_ap', ...
    cl_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Patch Verification mAP [%]');
  %set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure.
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, sprintf('verif_%s.png', ...
      det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('cval_verif_%s.tikz', ...
      det_sets(dsi).name)), 'showInfo', false, ...
      'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

% Matching

for dsi = 1:numel(det_sets)
  figure(102+dsi); clf;
  detnames = det_sets(dsi).detnames;
  rproc.bar_plot(res.matching_gen, 'mean_mean_ap', ...
    m_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Image Matching mAP [%]');
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, sprintf('matching_%s.png', ...
    det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('cval_matching_%s.tikz', ...
    det_sets(dsi).name)), 'showInfo', false, ...
    'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

% Retrieval
for dsi = 1:numel(det_sets)
  figure(1003+dsi); clf; 
  detnames = det_sets(dsi).detnames;
  rproc.bar_plot(res.retrieval_en, 'mean_mauc', ...
    r_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Patch Retrieval mAP [%]');
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, ...
    sprintf('retr_patch_%s.png', det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('cval_retr_patch_%s.tikz', ...
    det_sets(dsi).name)), 'showInfo', false, ...
    'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

%%


%% Print the TeX macros

res_tex_path = fullfile(outpath, 'cval-det-names.tex');
fd = fopen(res_tex_path, 'w');
of = @(varargin) [fprintf(fd, varargin{:}), fprintf(varargin{:})];


names = [{bnames.printname}, {bnames_pca.printname}];
tex_names = [{bnames.texname}, {bnames_pca.texname}];
of('\n');
for ni = 1:numel(names)
  of('\\newcommand{%s}{{\\ttb{%s}}\\xspace}\n', names{ni}, tex_names{ni});
end
of('\n');

fclose(fd);

%%


res_tex_path = fullfile(outpath, 'cval-det-stats.tex');
fd = fopen(res_tex_path, 'w');
of = @(varargin) [fprintf(fd, varargin{:}), fprintf(varargin{:})];

of('\n\n');
for bi = 1:numel(bnames)
  alpha = 0.5;
  color = in_c((1-alpha).*bnames(bi).color + alpha, 1);
  of('\\definecolor{%s}{rgb}{%.3f,%.3f,%.3f}\n', bnames(bi).printname(2:end), ... 
    color(1), color(2), color(3));
end

of('\n\n\\begin{tabular}{ l | r r r r }\\toprule\n');
of('\\multirow{ 2}{*}{Desc.} & \\multirow{ 2}{*}{Dim.} & Input & \\multicolumn{ 2}{c}{Speed [kP/s]} \\\\\n');
of(' & & size & CPU & GPU \\\\ \\midrule \n');

for ri = 1:numel(bnames)
  det = bnames(ri);
  isbin_str = ''; if det.isbin, isbin_str = '^{*}'; end
  pps_str = sprintf('$%.1f$', det.pps/1000);
  pps_gpu_str = sprintf('$%.1f$', det.ppsgpu/1000);
  if isnan(det.ppsgpu), pps_gpu_str = '-'; end
  of(' \\cellcolor{%s} %s & $%s% 4d$ & $%d$ & %s & %s \\\\ \n', ...
    bnames(ri).printname(2:end), det.printname, isbin_str, det.dim, det.psize, pps_str, pps_gpu_str);
end

of(' \\bottomrule \n \\end{tabular}\n');
fclose(fd);

%%

res_tex_path = fullfile(outpath, 'cval-det-stats-vert.tex');
fd = fopen(res_tex_path, 'w');
of = @(varargin) [fprintf(fd, varargin{:}), fprintf(varargin{:})];
of('\n\n');
for bi = 1:numel(bnames)
  of('\\definecolor{%s}{rgb}{%.3f,%.3f,%.3f}\n', bnames(bi).name, ...
    bnames(bi).color(1),  bnames(bi).color(2),  bnames(bi).color(3));
end

of('\n\n\\begin{tabular}{| l | %s |}\\hline\n', repmat(' r ', 1, numel(bnames)));

of('Desc. ');
for ri = 1:numel(bnames)
  of('& \\cellcolor{%s} \\rot{%s} ', bnames(ri).name, bnames(ri).printname);
end
of(' \\\\  \\hline \n');


of('Dim ');
for ri = 1:numel(bnames)
  isbin_str = ''; if bnames(ri).isbin, isbin_str = '^{*}'; end;
  of('& $%s%d$', isbin_str, bnames(ri).dim);
end
of(' \\\\ \n');

of('Input Sz %s \\\\ \n', sprintf('& %d ', bnames.psize));

of('Speed');
for ri = 1:numel(bnames)
  isgpu_str = ''; if bnames(ri).gpu, isgpu_str = '^{\dagger}'; end;
  of('& $%s%.0f$ ', isgpu_str, bnames(ri).pps ./ 1000);
end
of(' \\\\ \n');

%for ri = 1:numel(bnames)
%  det = bnames(ri);
%  isbin_str = ''; if det.isbin, isbin_str = '^{*}'; end;
%  isgpu_str = ''; if det.gpu, isgpu_str = '^{\dagger}'; end;
%  psz_str = strrep(det.psize, 'x', '\times');
%  of('\\textbf{% 10s} & $%s% 4d$ & $%s$ & $%s% 8.0f$ \\\\ \n', ...
%    det.printname, isbin_str, det.dim, psz_str, isgpu_str, det.pps);
%end

of(' \\hline \n \\end{tabular}\n');
fclose(fd);


