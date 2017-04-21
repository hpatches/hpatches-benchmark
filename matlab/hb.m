function res = hb(cmd, varargin)
%HB HPatches command line interface
%  `HB help`
%     Print this help string.
%  `HB help COMMAND`
%     Print a help string for a COMMAND.
%
%  `HB dataset`
%     Provision the HPatches dataset to `<hb_root>/data/hpatches_v1.1/`.
%
%  `HB computedesc DESCNAME`
%     Compute descriptor DESCNAME for patch images stored in
%     `<hb_root>/data/hpatches_v1.1/`. Supported descriptors are:
%
%     * sift, rootsift, meanstd, resize
%
%     For your own descriptor, add a function DESCNAME to
%     +desc/+feats/DESCNAME.m
%
%  `HB all DESCNAME`
%  `HB verification | matching | retrieval DESCNAME`
%     Run all or selected benchmarks for a descriptor DESCNAME.
%     Descriptor must be stored in `<hb_root>/data/descriptors/DESCNAME/`
%     as  `SEQ_NAME/IMNAME.csv` in comma separated files (one descriptor
%     per line).
%     By default, stores the results in CSV files in:
%     `<hb_root>/scores/<DESCNAME>/<BENCHNAME>.csv`
%     If tresults file exist, the computation is skipped. Use
%     `'override', true'` to overwrite existing score files. You can change
%     the scores path with the `'scoresroot', 'newpath'` option.
%
%     You can additionally configure the descriptor normalisation
%     with `'norm', true`, see `hb help norm` for additional arguments.

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
hb_setup();

cmds = struct();
cmds.all = struct('fun', @bench.all, 'help', '');
cmds.verification = struct('fun', @bench.verification, 'help', '');
cmds.matching = struct('fun', @bench.matching, 'help', '');
cmds.retrieval = struct('fun', @bench.retrieval, 'help', '');
cmds.computedesc = struct('fun', @desc.compute, 'help', '');
cmds.packdesc = struct('fun', @desc.pack, 'help', '');
cmds.dataset = struct('fun', @utls.get_hpatches, 'help', '');
cmds.norm = struct('fun', '', 'help', @(varargin) help('desc.normdesc'));

% The last command is always help
cmds.help.fun = '';
cmds.help.help = @(varargin) usage(cmds);
cmds.help = struct('fun', @(varargin) usage(cmds, varargin{:}));
if nargin < 1, cmd = nan; end;
if ~ischar(cmd), usage(cmds); return; end
if strcmp(cmd, 'commands'), res = cmds; return; end;

if isfield(cmds, cmd) && ~isempty(cmds.(cmd).fun)
  cmds.(cmd).fun(varargin{:});
else
  error('Invalid command. Run hb help for list of valid commands');
end

end

function usage(cmds, cmd)
name = 'hb';
if isdeployed(), name = 'run_hb.sh'; end;
if nargin == 1
  fprintf('Usage: `%s COMMAND ...\n', name);
  help('hb');
  if usejava('desktop')
    fprintf('Valid commands:\n\t');
    cmd_names = fieldnames(cmds);
    for ci = 1:(numel(cmd_names)-1)
      fprintf('<a href="matlab: hb help %s">%s</a>  ', ...
        cmd_names{ci}, cmd_names{ci});
    end
    fprintf('\n');
  else
    fprintf('Valid commands: %s\n\n', strjoin(fieldnames(cmds), ', '));
  end
else
  if isfield(cmds, cmd)
    fprintf('Help for %s command `%s`:\n', name, cmd);
    if isempty(cmds.(cmd).help)
      help(func2str(cmds.(cmd).fun));
    else
      cmds.(cmd).help(cmd);
    end
  else
    error('Invalid command. Run hb help for list of valid commands');
  end
end
end
