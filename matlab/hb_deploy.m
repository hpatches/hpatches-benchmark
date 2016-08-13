function hb_deploy()
% HB_DEPLOY Deploy the command line interface of the HBenchmark

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

hb_setup();
target_dir = fullfile(hb_path, 'bin');
dependecies = {};
switch computer
  case 'GLNXA64'
    dependecies{end+1} = '-a';
    dependecies{end+1} = fullfile(vl_root, 'toolbox', 'mex', mexext,'libvl.so');
  otherwise
    error('Unsupported architecture.');
end

mcc('-m', 'hb.m', '-d', target_dir, '-o', 'hb', ...
  dependecies{:});

end

