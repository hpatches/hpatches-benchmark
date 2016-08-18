function hb(cmd, descname, taskname, varargin)
%HBenchmarks command line interface
%  `HB COMMAND DESCNAME BENCHMARKNAME` Is a general call of the HBenchmarks
%  command line interface. The supported commands are:
%
%  `HB checkdesc DESCNAME`
%    Check the validity of the descriptors located in:
%      data/descriptors/DESCNAME/<sequence_name>/<patchimage>.csv
%
%  `HB pack DESCNAME`
%    Run evaluation on all benchmark files defined in `./benchmarks/` and
%    pack the results to `DESCNAME_results.zip`.
%    Descriptors `DESCNAME` **must** be stored in an appropriate folders.
%    This commands computes the results only for tasks, where the results
%    file does not exist. To recompute all the results, call:
%    ```
%    HB pack DESCNAME * override true
%    ```
%    or delete the appropriate `.results` file.
%    This command also makes sure that the submission name and contact
%    email address are stored in `data/descriptors/DESCNAME/info.txt`.
%
%    Please note that the classification benchmark loads the descriptors to
%    memory.
%
%  `HB computedesc DESCNAME`
%    Compute some of the provided baseline descriptors. Supported
%    descriptors currently are:
%      * `sift`     - SIFT descriptor (VLFeat implementation)
%      * `meanstd`  - 2D descriptor with mean and standard deviation of a patch
%      * `resize`   - resize patch into 4x4 patch and perform meanstd norm.
%
%  `HB TASK DESCNAME BENCHMARKNAME`
%    Compute results only for a specified .benchmark file stored in:
%    ```
%      benchmarks/TASK/BENCHMARKNAME.benchmark
%    ```
%    And TASK is one of `classification`, `retrieval` or `matching`.
%    BENCHMARKNAME can contain an asterisk `*` wildcard. E.g. to run all
%    train retrieval task, call:
%    ```
%      HB retrieval DESCNAME train_*
%    ```
%    This always overwrites existing results files. Results will be stored
%    in:
%    ```
%      results/DESCNAME/retrieval/BENCHMARKNAME.results
%    ```
%
%    Please note that the classification benchmark caches descriptors in
%    memory.
%
%  `HB packdesc DESCNAME`
%     Pack all the descriptors DESCNAME to `DESCNAME_descriptors.zip`.
%
%  `HB help`
%     Print this help string.

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
hb_setup();
opts.packWildCard = '*';
opts.override = [];
[opts, varargin] = vl_argparse(opts, varargin);
valid_commands = {'pack', 'checkdesc', 'computedesc', 'classification', ...
  'matching', 'retrieval', 'packdesc', 'help'};
if nargin == 0
  fprintf(isdeployed+1, 'Nothing to do.\n');
  usage(valid_commands); return;
end;
if nargin == 1
  if strcmp(cmd, 'help')
    fprintf(isdeployed+1, '%s\n', evalc('help hb'));
    return;
  end
  fprintf(isdeployed+1, 'Missing DESCNAME.\n');
  usage(valid_commands); return;
end;
if nargin == 2, taskname = opts.packWildCard; end;
cmd = lower(cmd); descname = lower(descname);
imdb = hpatches_dataset();

% Check the command
if ~ischar(cmd) || ~ismember(cmd, valid_commands) || ~ischar(descname) || ...
  ~ischar(taskname)
  usage(valid_commands);
  return;
end

% Chech validity of the descritpros
desc_path = fullfile(hb_path, 'data', 'descriptors', descname);
if ~ismember(cmd,  {'computedesc'}) && ~exist(desc_path, 'dir')
  error('Unable to find descriptors in `%s`.', desc_path);
end
desc_fun = @(a, b) desc_none(a, b, descname);

% Handle the wildcard task names
if ~isempty(strfind(taskname, '*')) && ...
    ~ismember(cmd, {'pack', 'checkdesc', 'packdesc', 'computedesc'})
  task_names = cellfun(@(a)strrep(strrep(a, '_pos', ''), '_neg', ''), ...
    listtasks(cmd, taskname), 'UniformOutput', false);
  task_names = sort(unique(task_names));
  fprintf(isdeployed+1, 'Processing %d tasks: %s\n', numel(task_names), ...
    strjoin(task_names, ', '));
  for ti = 1:numel(task_names)
    hb(cmd, descname, task_names{ti}, 'override', opts.override);
  end
  return;
end

switch cmd
  case {'classification', 'matching', 'retrieval'}
    bench_file = fullfile(hb_path, 'benchmarks', cmd, [taskname, '.benchmark']);
    if ~exist(bench_file, 'file'), error('Unable to find %s.', bench_file); end;
    res_file = fullfile(hb_path, 'results', descname, cmd, [taskname, '.results']);
    done_file = utls.get_donepath(res_file);

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
    % TODO ask for contact details.
    % TODO check if test set available
    hb('checkdesc', descname);
    fprintf('Packing all results for descriptor %s.\n', descname);
    fprintf('Please not that this does not recompute existing results.\n');
    commands = {'classification', 'retrieval', 'matching'};
    for ci = 1:numel(commands)
      task_names = listtasks(commands{ci}, taskname);
      for ti = 1:numel(task_names)
        [valid, resfile] = checkresults(commands{ci}, descname, task_names{ti});
        if ~valid || ~isempty(opts.override)
          warning('Invalid results file %s. Recomputing.', resfile);
          tn = strrep(strrep(task_names{ti}, '_pos', ''), '_neg', '');
          hb(commands{ci}, descname, tn, 'override', opts.override);
        end
      end
    end
    getdescinfo(descname);
    zipFile = fullfile(hb_path, [descname, '_results.zip']);
    fprintf('Packing the results to %s.\n', zipFile);
    zip(zipFile, fullfile(hb_path, 'results', descname));
    submitLink = utls.readfile(fullfile(hb_path, 'results', 'submit.url'));
    fprintf('\nDone. Please submit the file:\n\t%s\nto:\n\t%s\n', ...
      zipFile, submitLink{1});
  case 'packdesc'
    hb('checkdesc', descname);
    getdescinfo(descname);
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
    fprintf('Descriptors stored in %s.\n', desc_path);
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
  case 'computedesc'
    switch descname
      case 'sift'
        desc_fun = @desc_patch_sift;
      case 'meanstd'
        desc_fun = @desc_patch_meanstd;
      case 'resize'
        desc_fun = @(varargin) desc_patch_resize(6, varargin{:});
      otherwise
        error('Unsupported baseline descriptor.');
    end
    fprintf('Computing %s descriptor for %d sequences.\n', descname, ...
      numel(imdb.sequences.name));
    cache_all_desc(imdb, desc_fun, descname);
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

function getdescinfo(descname)
descInfoFile = fullfile(hb_path, 'data', 'descriptors', descname, 'info.txt');
if ~exist(descInfoFile, 'file') ||...
    numel(utls.readfile(descInfoFile)) ~= 2
  fprintf('\nTo continue, we need to know few details about your submission:\n');
  submissisonName = input('Please enter submission name: ', 's');
  emailAddress = input('Please enter contact email: ', 's');
  ifd = fopen(descInfoFile, 'w');
  fprintf(ifd, '%s\n%s', submissisonName, emailAddress);
  fclose(ifd);
  fprintf('Submission info wrote to %s. Edit this file for changes.\n', ...
    descInfoFile);
end
end

function usage(valid_commands)
fprintf(isdeployed+1, 'Usage: `run_hb.sh COMMAND DESCNAME BENCHMARK`\n');
fprintf(isdeployed+1, 'Valid commands: %s\n', strjoin(valid_commands, ', '));
fprintf(isdeployed+1, 'See `hb_run.sh help` for help.\n');
end