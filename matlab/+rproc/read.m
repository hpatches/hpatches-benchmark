function res = read(varargin)
opts.scoresroot = fullfile(hb_path, 'scores_new');
opts = vl_argparse(opts, varargin);
scoresroot = opts.scoresroot;
dirs = utls.listdirs(scoresroot);

res.verification = cell(1, numel(dirs));
res.matching = cell(1, numel(dirs));
res.retrieval = cell(1, numel(dirs));

for resi = 1:numel(dirs)
  res.verification{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'verification.csv'));
  res.matching{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'matching.csv'));
  res.retrieval{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'retrieval.csv'));
end
res.verification = vertcat(res.verification{:});
res.matching = vertcat(res.matching{:});
res.retrieval = vertcat(res.retrieval{:});
end
