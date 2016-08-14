function hb_deploy()
% HB_DEPLOY Deploy the command line interface of the HBenchmark

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

hb_setup();
target_dir = fullfile(hb_path, 'bin');
dependecies = vl_deps();

mcc('-m', 'hb.m', '-d', target_dir, '-o', 'hb', ...
  dependecies{:});

end

function depargs = vl_deps()
archs = struct();
archs.mexw64 = '*.dll'; archs.mexw32 = '*.dll';
archs.mexmaci64 = '*.dylib'; archs.mexmaci32 = '*.dylib';
archs.mexa64 = '*.so'; archs.mexaglx = '*.so';

depargs = {};
mexdir = fullfile(vl_root, 'toolbox', 'mex', mexext);
libs = dir(fullfile(mexdir, archs.(mexext)));
for li = 1:numel(libs)
  depargs{end+1} = '-a';
  depargs{end+1} = fullfile(mexdir, libs(li).name);
end

end