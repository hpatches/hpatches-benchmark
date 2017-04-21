function dpath = hb_path()
%HB_PATH Return the root path of HBenchmarks

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if isdeployed
  % assume that the script is being run either from root or from bin
  paths = {pwd, fullfile(pwd, '..')};
  for pi = 1:numel(paths)
    path = paths{pi};
    if exist(fullfile(path, 'benchmarks'), 'dir') && ...
       exist(fullfile(path, 'matlab'), 'dir')
     dpath = path;
     return;
    end
  end
  error('Hbenchmarks not found.');
else
  funpath = fileparts(mfilename('fullpath'));
  dpath = fullfile(fileparts(funpath));
end