function setup_matconvnet(varargin)
opts.url = 'https://github.com/vlfeat/matconvnet/archive/master.zip';
opts.rootDir = fullfile(hb_path('vendor'), 'matconvnet');
opts = vl_argparse(opts, varargin);

if ~exist('vl_nnconv', 'file')
  utls.provision(opts.url, opts.rootDir);
  run(fullfile(getlatest(opts.rootDir, 'matconvnet'), 'matlab', 'vl_setupnn.m'));
  
  if ~contains(which('vl_nnconv'), mexext)
    fprintf('MatConvNet not compiled. Attempting to run `vl_compilenn` (CPU ONLY, no imreadjpeg).\n');
    fprintf('To compile with a GPU support, see `help vl_compilenn`.');
    vl_compilenn('EnableImreadJpeg', false);
  end
end

end

function out = getlatest(path, name)
sel_dir = dir(fullfile(path, [name '*']));
sel_dir = sel_dir([sel_dir.isdir]);
sel_dir = sort({sel_dir.name});
out = fullfile(path, sel_dir{end});
end