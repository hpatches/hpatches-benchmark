desc_funs = {@desc.feats.kde, @desc.feats.mkd, ...
  @(a) desc.feats.l2net(a, 'flagGpu', false), @(a) desc.feats.l2net(a, 'flagGpu', true), ...
  @(a) desc.feats.tnet(a, 'flagGpu', false), @(a) desc.feats.tnet(a, 'flagGpu', true)};
desc_funs = {@desc.feats.mkd};
dspeeds = zeros(1, numel(desc_funs));
npatches = zeros(1, numel(desc_funs));
n_seq = 20;
n_im = 2;


datasetPath = fullfile(hb_path, 'data', 'hpatches-release');

sequences = utls.listdirs(datasetPath);
for di = 1:numel(desc_funs)
  status = utls.textprogressbar(numel(sequences), 'startmsg', ...
    sprintf('Computing '), 'updatestep', 1);
  for si = 1:n_seq
    seq_name = sequences{si};
    seq_dir = fullfile(datasetPath, seq_name);
    imgs = dir(fullfile(seq_dir, '*.png'));
    for imi = 1:n_im
      [~, imname, imext] = fileparts(imgs(imi).name);
      impath = fullfile(seq_dir, [imname, imext]);
      patches = desc.load_hpatches(impath);
      [des, info] = desc_funs{di}(patches);
      dspeeds(di) = dspeeds(di)+info.time;
      npatches(di) = npatches(di)+size(patches, 4);
    end
    status(si);
  end
end
%%

fprintf('\n');
fprintf('%.2f\n', npatches ./ dspeeds)