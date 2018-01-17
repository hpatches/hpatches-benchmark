function setup_vlfeat()
url = 'http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz';
rootDir = fullfile(hb_path('vendor'), 'vlfeat');
if ~exist('vl_argparse.m', 'file')
  utls.provision(url, rootDir);
  run(fullfile(getlatest(rootDir, 'vlfeat'), 'toolbox', 'vl_setup.m'));
end
end

function out = getlatest(path, name)
sel_dir = dir(fullfile(path, [name '*']));
sel_dir = sel_dir([sel_dir.isdir]);
sel_dir = sort({sel_dir.name});
out = fullfile(path, sel_dir{end});
end