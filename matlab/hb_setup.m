function hb_setup()
% HB_SETUP Set up the HBenchmarks

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

if ~isdeployed && (exist('hb', 'file') || ~exist('vl_argparse', 'file'))
  warning('off', 'MATLAB:maxNumCompThreads:Deprecated');
  if maxNumCompThreads > 1, maxNumCompThreads(1); end;
  setenv('OMP_NUM_THREADS','1');
  setenv('MKL_NUM_THREADS','1');
  
  % Provision VLFeat
  utls.provision(fullfile(hb_path, 'matlab', 'data', 'vlfeat.url'), ...
    fullfile(hb_path, 'matlab', 'vlfeat'), true);
  vlf_dir = dir(fullfile(hb_path, 'matlab', 'vlfeat', 'vlfeat*'));
  vlf_dir = vlf_dir([vlf_dir.isdir]);
  run(fullfile(hb_path, 'matlab', 'vlfeat', vlf_dir(1).name, 'toolbox', 'vl_setup.m'));
  addpath(fullfile(hb_path(), 'matlab'));
end
