function hb_setup()
% HB_SETUP Set up the HBenchmars

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

if isdeployed, return; end;
funpath = fileparts(mfilename('fullpath'));
if ~exist(fullfile(funpath, 'vlfeat'), 'dir')
  fprintf('Downloading VLFeat...\n');
  untar('http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz', funpath);
  movefile(fullfile(funpath, 'vlfeat-0.9.20'), fullfile(funpath, 'vlfeat'));
  fprintf('Done.\n');
end
run(fullfile(funpath, 'vlfeat', 'toolbox', 'vl_setup.m'));
