function stats = hpatchstats(varargin)

p = inputParser();
p.addParameter('datasetPath', fullfile(hb_path, 'data', 'hpatches-release'), ...
  @(a) exist(a, 'dir'));
p.addParameter('imageExt', '*.png', @ischar);
p.parse(varargin{:});
opts = p.Results();

sequences = utls.listdirs(opts.datasetPath);
status = utls.textprogressbar(numel(sequences), 'startmsg', ...
  sprintf('Computing stats'), 'updatestep', 1);
stats.all = 0; stats.r = 0;
stats.e = 0; stats.h = 0; stats.t = 0;
stats.sequences = sequences;
stats.npseq = zeros(1, numel(sequences));
for si = 1:numel(sequences)
  seq_name = sequences{si};
  seq_dir = fullfile(opts.datasetPath, seq_name);
  imgs = dir(fullfile(seq_dir, opts.imageExt));
  for imi = 1:numel(imgs)
    [~, imname, imext] = fileparts(imgs(imi).name);
    impath = fullfile(seq_dir, [imname, imext]);
    patches = desc.load_hpatches(impath);
    stats.all = stats.all + size(patches, 4);
    stats.(imname(1)) = stats.(imname(1)) + size(patches, 4);
    stats.npseq(si) = stats.npseq(si) + size(patches, 4);
  end
  status(si);
end

end
