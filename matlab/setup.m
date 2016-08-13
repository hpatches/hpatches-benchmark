function setup()
funpath = fileparts(mfilename('fullpath'));
if ~exist(fullfile(funpath, 'vlfeat'), 'dir')
  fprintf('Downloading VLFeat...\n');
  untar('http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz', funpath);
  movefile(fullfile(funpath, 'vlfeat-0.9.20'), fullfile(funpath, 'vlfeat'));
  fprintf('Done.\n');
end
run(fullfile(funpath, 'vlfeat', 'toolbox', 'vl_setup.m'));
