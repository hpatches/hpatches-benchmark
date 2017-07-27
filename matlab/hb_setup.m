function hb_setup()
% HB_SETUP Set up the HBenchmarks

% Copyright (C) 2016, 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

if ~isdeployed && (exist('hb', 'file') || ~exist('vl_argparse', 'file'))
  if ~isempty(getenv('SGE_TASK_ID'))
    % In parallel environments use only a single thread
    warning('off', 'MATLAB:maxNumCompThreads:Deprecated');
    if maxNumCompThreads > 1, maxNumCompThreads(1); end;
    setenv('OMP_NUM_THREADS','1');
    setenv('MKL_NUM_THREADS','1');
  end
  
  addpath(fullfile(hb_path(), 'matlab'));  
  run(fullfile(hb_path, 'matlab', 'lib', 'vlfeat', 'vlfeat_setup.m'));
end
