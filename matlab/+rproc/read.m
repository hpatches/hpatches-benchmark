function res = read(varargin)
opts.scoresroot = fullfile(hb_path, 'scores_new');
opts.dataset = 'hp';
opts = vl_argparse(opts, varargin);
scoresroot = opts.scoresroot;
dirs = utls.listdirs(scoresroot);

status = utls.textprogressbar(numel(dirs), 'updatestep', 1, ...
  'startmsg', 'Loading results');
switch opts.dataset
  case {'hpatches', 'hp'}
    res.verification = cell(1, numel(dirs));
    res.matching = cell(1, numel(dirs));
    res.retrieval = cell(1, numel(dirs));
    for resi = 1:numel(dirs)
      res.verification{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'verification.csv'), 'Delimiter', ',');
      res.matching{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'matching.csv'), 'Delimiter', ',');
      res.retrieval{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'retrieval.csv'), 'Delimiter', ',');
      status(resi);
    end
    res.verification = vertcat(res.verification{:});
    res.matching = vertcat(res.matching{:});
    res.retrieval = vertcat(res.retrieval{:});
  case {'phototourism', 'pt'}
    res.verification_pt = cell(1, numel(dirs));
    for resi = 1:numel(dirs)
      res.verification_pt{resi} = readtable(fullfile(scoresroot, dirs{resi}, 'verification-pt.csv'), 'Delimiter', ',');
      status(resi);
    end
    res.verification_pt = vertcat(res.verification_pt{:});
end
end
