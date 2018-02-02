hb_setup();

res = rproc.read('scoresroot', ...
  fullfile(hb_path, 'matlab', 'scores', 'scores_all_cval_trained'));

%%
outpath = fullfile(hb_path, 'matlab', 'results', 'article_cval_trained');
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

%%
res.verification_e = rproc.postproc_trained(res.verification);
res.matching_ge = rproc.postproc_trained(res.matching_g);
res.retrieval_e = rproc.postproc_trained(res.retrieval);

res.verification_e(ismember(res.verification_e.split, {'view', 'illum'}), :) = [];
res.matching_ge(ismember(res.matching_ge.split, {'view', 'illum'}), :) = [];
res.retrieval_e(ismember(res.retrieval_e.split, {'view', 'illum'}), :) = [];


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
colors.hardnetlibp = in_c(utls.rgb('Red'), cip);

%

trained = {}; cip = 1;
ls = {'EdgeColor', [1, 1, 1] * 0}; lsn = {'EdgeColor', [1, 1, 1] * 0, 'LineStyle', '-.'};
%trained{end+1} = struct('name', 'wlrn', 'printname', '\wlrn', 'texname', 'WLRN', ...
%  'color', in_c(utls.rgb('Goldenrod'), cip), 'barargs', {ls});
trained{end+1} = struct('name', 'meanstd', 'printname', '\meanstd', 'texname', 'MStd', ...
  'color', colors.resize, 'barargs', {ls});
trained{end+1} = struct('name', 'sift', 'printname', '\sift', 'texname', 'SIFT', ...
  'color', colors.sift, 'barargs', {ls});


trained{end+1} = struct('name', 'tfeat-n-lib', 'printname', '\tfn', 'texname', 'TF', ...
  'color', colors.tfeatnlib, 'barargs', {ls});
trained{end+1} = struct('name', 'HardNetLib+', 'printname', '\hardnetplus', 'texname', 'HardNetLib', ...
  'color', colors.hardnetlibp, 'barargs', {ls});

trained{end+1} = struct('name', 'tfeat', ...
  'printname', '\tfntrained', 'texname', 'TF-tr', ...
  'color', in_c(colors.tfeatnlib, 0.8), 'barargs', {lsn});
trained{end+1} = struct('name', 'hp', ...
  'printname', '\hardnetrained', 'texname', 'HNet-tr', ...
  'color', in_c(colors.hardnetlibp, 0.8), 'barargs', {lsn});

trained = cell2mat(trained);

trained_s = struct('name', {trained.name}, 'printname', {trained.printname}, ...
  'color', {trained.color}, ...
  'bararg', {trained.barargs});
%
det_sets = {};

det_sets{end+1}.dets = trained_s;
det_sets{end}.detnames = {trained_s.printname};
det_sets{end}.name = 'trained';

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
  rproc.bar_plot(res.verification_e, 'pr_ap', ...
    cl_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Patch Verification mAP [%]');
  %set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure.
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, sprintf('trained_verif_%s.png', ...
      det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('trained_verif_%s.tikz', ...
      det_sets(dsi).name)), 'showInfo', false, ...
      'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

% Matching

for dsi = 1:numel(det_sets)
  figure(102+dsi); clf;
  detnames = det_sets(dsi).detnames;
  rproc.bar_plot(res.matching_ge, 'mean_ap', ...
    m_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Image Matching mAP [%]');
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, sprintf('trained_matching_%s.png', ...
    det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('trained_matching_%s.tikz', ...
    det_sets(dsi).name)), 'showInfo', false, ...
    'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

% Retrieval
for dsi = 1:numel(det_sets)
  figure(1003+dsi); clf; 
  detnames = det_sets(dsi).detnames;
  rproc.bar_plot(res.retrieval_e, 'mauc', ...
    r_tasks, det_sets(dsi).dets, 'detnames', detnames, ...
    'legend', false);
  xlabel('Patch Retrieval mAP [%]');
  drawnow;
  vl_printsize(ps);
  out_im_path = fullfile(outpath, ...
    sprintf('trained_patch_%s.png', det_sets(dsi).name));
  print('-dpng', out_im_path, '-r200');
  matlab2tikz(fullfile(outpath, sprintf('trained_retr_patch_%s.tikz', ...
    det_sets(dsi).name)), 'showInfo', false, ...
    'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false);
end

%%


%% Print the TeX macros

res_tex_path = fullfile(outpath, 'trained-det-names.tex');
fd = fopen(res_tex_path, 'w');
of = @(varargin) [fprintf(fd, varargin{:}), fprintf(varargin{:})];


names = [{trained.printname}];
tex_names = [{trained.texname}];
of('\n');
for ni = numel(names)-1:numel(names)
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


