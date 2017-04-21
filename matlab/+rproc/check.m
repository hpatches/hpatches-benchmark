function check(varargin)
% Check whether all results are computed for the scores directories

opts.scoresroot = fullfile(hb_path, 'matlab', 'scores', 'default');
opts = vl_argparse(opts, varargin);
res_path = opts.scoresroot;
dirs = utls.listdirs(res_path);
mi = false(3, numel(dirs));

for resi = 1:numel(dirs)
  fprintf('%s:\n', dirs{resi});
  verif_f = fullfile(res_path, dirs{resi}, 'verification.csv');
  if ~exist(verif_f, 'file')
    fprintf('\t%s does not exist.\n', verif_f);
    mi(1, resi) = true;
  end;
  match_f = fullfile(res_path, dirs{resi}, 'matching.csv');
  if ~exist(match_f, 'file')
    fprintf('\t%s does not exist.\n', match_f);
    mi(2, resi) = true;
  end;
  retr_f = fullfile(res_path, dirs{resi}, 'retrieval.csv');
  if ~exist(retr_f, 'file')
    fprintf('\t%s does not exist.\n', retr_f);
    mi(3, resi) = true;
  end;
end
fprintf('%d Results, %d incomplete.\n', numel(dirs), sum(sum(mi, 1) > 0));
end
