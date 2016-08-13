function hb(cmd, descname, taskname, varargin)
% HP Main command line entrypoint for the deployed application
%   HP(COMMAND, DESCNAME, TASKNAME) Runs the benchmark task with a
%   precomputed descriptor files. Descriptors must be stored in:
%
%   <hbench_root>/data/descriptors/DESCNAME/<sequence_name>/<im_name>.csv

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

valid_commands = {'classification', 'matching', 'retrieval'};
if nargin == 0 || ~ischar(cmd) || nargin == 0 || ...
    ~ismember(cmd, valid_commands)
  usage(valid_commands);
  return;
end

desc_path = fullfile(hb_path, 'data', 'descriptors', descname);
if ~exist(desc_path, 'dir')
  error('Unable to find descriptors in `%s`.', desc_path);
end
imdb = hpatches_dataset();
desc_fun = @(a, b) desc_none(a, b, descname);

switch cmd
  case 'classification'
    pos_pairs = fullfile(hb_path, 'benchmarks', 'classification', ...
      [taskname, '_pos.pairs']);
    if ~exist(pos_pairs, 'file')
      error('Unable to find %s.', pos_pairs);
    end;
    neg_pairs = fullfile(hb_path, 'benchmarks', 'classification', ...
      [taskname, '_neg.pairs']);
    if ~exist(neg_pairs, 'file')
      error('Unable to find %s.', neg_pairs);
    end;
    
    pos_res = fullfile(hb_path, 'results', descname, ...
      'classification', [taskname, '_pos.results']);
    neg_res = fullfile(hb_path, 'results', descname, ...
      'classification', [taskname, '_neg.results']);
    
    classification_compute(pos_pairs, desc_fun, pos_res, ...
      'cacheName', descname, 'imdb', imdb);
    classification_compute(neg_pairs, desc_fun, neg_res, ...
      'cacheName', descname, 'imdb', imdb);
    
    res = classification_eval(pos_res, neg_res, varargin{:});
    fprintf(isdeployed+1, 'Classification results:\n');
    fprintf('%s\tpatch_classif_auc\t%.4f\tpatch_classif_ap\t%.4f\n', ...
      descname, res.auc*100, res.ap*100);
  case {'matching', 'retrieval'}
    bench_file = fullfile(hb_path, 'benchmarks', cmd, [taskname, '.benchmark']);
    if ~exist(bench_file, 'file'), error('Unable to find %s.', bench_file); end;
    res_file = fullfile(hb_path, 'results', descname, ...
      cmd, [taskname, '.results']);

    switch cmd
      case 'matching'
        matching_compute(bench_file, desc_fun, res_file, ...
          'cacheName', descname, 'imdb', imdb);
      case 'retrieval'
        retrieval_compute(bench_file, desc_fun, res_file, ...
          'cacheName', descname, 'imdb', imdb);
    end
    
    labels_file = fullfile(hb_path, 'benchmarks', cmd, [taskname, '.labels']);
    if ~exist(labels_file, 'file')
      fprintf('Labels file does not exist.\n');
      return;
    end
    switch cmd
      case 'matching'
        res = matching_eval(bench_file, labels_file, res_file, varargin{:});
        fprintf('%s\timage_matching_map\t%.4f\n', descname, mean([res(:).ap])*100);
      case 'retrieval'
        res = retrieval_eval(bench_file, labels_file, res_file, varargin{:});
        fprintf('%s\timage_retr_map\t%.4f\tpatch_retr_map\t%.4f\n', ...
          descname, mean(res.image_retr_ap(:))*100, mean(res.patch_retr_ap(:))*100);
    end
  case 'help'
    usage;
  otherwise
    error('Unknown command.');
end

end

function usage()
fprintf(2, 'Usage: `run_hb command desc_name task_name`\n');
end