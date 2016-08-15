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
hb_setup();
opts.packWildCard = '*';
opts.override = true;
[opts, varargin] = vl_argparse(opts, varargin);
imdb = hpatches_dataset();
if nargin == 2, taskname = opts.packWildCard; end;
if ischar(opts.override), opts.override = strcmp(opts.override, 'true'); end;

% Check the command
valid_commands = {'classification', 'matching', 'retrieval', 'pack', ...
  'checkdesc', 'packdesc'};
if nargin == 0 || ~ischar(cmd) || nargin == 0 || ...
    ~ismember(cmd, valid_commands)
  usage(valid_commands);
  return;
end

% Chech validity of the descritpros
desc_path = fullfile(hb_path, 'data', 'descriptors', descname);
if ~exist(desc_path, 'dir')
  error('Unable to find descriptors in `%s`.', desc_path);
end
desc_fun = @(a, b) desc_none(a, b, descname);

% Handle the wildcard task names
if ~isempty(strfind(taskname, '*')) && ...
    ~ismember(cmd, {'pack', 'checkdesc', 'packdesc'})
  task_names = cellfun(@(a)strrep(strrep(a, '_pos', ''), '_neg', ''), ...
    listtasks(cmd, taskname));
  task_names = sort(unique(task_names));
  fprintf(isdeployed+1, 'Processing %d tasks: %s\n', numel(tasks_names), ...
    strjoin(task_names, ', '));
  for ti = 1:numel(task_names)
    hb(cmd, descname, task_names{ti}, 'override', opts.override);
  end
end

switch cmd
  case {'classification', 'matching', 'retrieval'}
    bench_file = fullfile(hb_path, 'benchmarks', cmd, [taskname, '.benchmark']);
    if ~exist(bench_file, 'file'), error('Unable to find %s.', bench_file); end;
    res_file = fullfile(hb_path, 'results', descname, cmd, [taskname, '.results']);
    done_file = utls.get_donepath(res_file);

    if ~exist(done_file, 'file') || opts.override
      switch cmd
        case 'classification'
          classification_compute(bench_file, desc_fun, res_file, ...
            'cacheName', descname)
        case 'matching'
          matching_compute(bench_file, desc_fun, res_file, ...
            'cacheName', descname);
        case 'retrieval'
          retrieval_compute(bench_file, desc_fun, res_file, ...
            'cacheName', descname);
      end
      df = fopen(done_file, 'w'); fclose(df);
    end
    
    labels_file = fullfile(hb_path, 'benchmarks', cmd, [taskname, '.labels']);
    if ~exist(labels_file, 'file')
      fprintf('Labels file does not exist.\n');
      return;
    end
    
    switch cmd
      case 'classification'
        res = classification_eval(bench_file, labels_file, res_file, varargin{:});
        fprintf('%s\tclassification_auc\t%.4f\tclassification_ap\t%.4f\n', ...
          descname, mean([res(:).auc])*100, mean([res(:).ap])*100);
      case 'matching'
        res = matching_eval(bench_file, labels_file, res_file, varargin{:});
        fprintf('%s\timage_matching_map\t%.4f\n', descname, mean([res(:).ap])*100);
      case 'retrieval'
        res = retrieval_eval(bench_file, labels_file, res_file, varargin{:});
        fprintf('%s\timage_retr_map\t%.4f\tpatch_retr_map\t%.4f\n', ...
          descname, mean(res.image_retr_ap(:))*100, mean(res.patch_retr_ap(:))*100);
    end
  case 'pack'
    fprintf('Packing all results for descriptor %s.\n', descname);
    fprintf('Please not that this does not recompute existing results.\n');
    commands = {'classification', 'retrieval', 'matching'};
    for ci = 1:numel(commands)
      task_names = listtasks(commands{ci}, taskname);
      for ti = 1:numel(task_names)
        [valid, resfile] = checkresults(commands{ci}, descname, task_names{ti});
        if ~valid
          warning('Invalid results file %s. Recomputing.', resfile);
          tn = strrep(strrep(task_names{ti}, '_pos', ''), '_neg', '');
          hb(commands{ci}, descname, tn, 'override', opts.override);
        end
      end
    end
    zipFile = fullfile(hb_path, [descname, '_results.zip']);
    fprintf('Packing the results to %s.\n', zipFile);
    zip(zipFile, fullfile(hb_path, 'results', descname));
    submitLink = utls.readfile(fullfile(hb_path, 'results', 'submit.url'));
    fprintf('\nDone. Please submit the file:\n\t%s\nto:\n\t%s\n', ...
      zipFile, submitLink{1});
  case 'packdesc'
    hb('checkdesc', descname);
    zipFile = fullfile(hb_path, [descname, '_descriptors.zip']);
    fprintf('Packing the descriptors to %s.\n', zipFile);
    zip(zipFile, fullfile(hb_path, 'data', 'descriptors', descname));
    submitLink = utls.readfile(fullfile(hb_path, 'results', 'submit.url'));
    fprintf('\nDone. Please submit the file:\n\t%s\nto:\n\t%s\n', ...
      zipFile, submitLink{1});
  case 'checkdesc'
    descdim = [];
    fprintf('Checking %s descriptors for %d sequences.\n', ...
      descname, numel(imdb.sequences.name));
    status = utls.textprogressbar(numel(imdb.sequences.name));
    for si = 1:numel(imdb.sequences.name)
      numPatches = imdb.sequences.npatches(si);
      for imi = 1:numel(imdb.sequences.images{si})
        sign = [imdb.sequences.name{si}, '.', imdb.sequences.images{si}{imi}];
        [descs, cachePath] = get_descriptors(imdb, sign, desc_fun, ...
          'cacheName', descname);
        if isempty(descdim)
          descdim = size(descs, 1);
        else
          if descdim ~= size(descs, 1)
            error(['Invalid descriptors in %s.\n',...
            'The dimensionality does not agree (%d vs %d)'], ...
              cachePath, size(descs, 1), descdim);
          end
        end
        if size(descs, 2) ~= numPatches
          error(['Invalid descriptors in %s.\n',...
            'Invalid number of descriptors (%d vs %d)'], ...
              cachePath, size(descs, 2), numPatches);
        end
      end
      status(si);
    end
    fprintf('All descriptors of %s appear to be valid.\n', descname);
  case 'help'
    usage(valid_commands);
  otherwise
    error('Unknown command.');
end

end

function task_names = listtasks(cmd, taskname)
  task_files = dir(fullfile(hb_path, 'benchmarks', cmd, [taskname, '.benchmark']));
  task_names = {task_files.name};
  for ti = 1:numel(task_names)
    [~, task_names{ti}] = fileparts(task_names{ti});
  end
end

function [valid, res_file] = checkresults(cmd, descname, taskname)
valid = false;
res_file = fullfile(hb_path, 'results', descname, cmd, [taskname, '.results']);
done_file = utls.get_donepath(res_file);
if ~exist(res_file, 'file') || ~exist(done_file, 'file'), return; end;
finfo = dir(res_file);
valid = ~finfo.isdir && finfo.bytes > 0;
end

function usage(valid_commands)
fprintf(isdeployed+1, 'Usage: `run_hb command desc_name task_name`\n');
fprintf(isdeployed+1, '%s\n', evalc('help hb'));
end