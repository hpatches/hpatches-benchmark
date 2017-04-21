function [ idxs ] = parallelise( varargin )
% PARALLELISE Return the scalar product of all arguments indexes
%   Eventually, if SGE_TASK_ID and SGE_TASK_LAST are set, selects only a
%   subset of the tasks.
nel_num = cellfun(@numel, varargin);
nel = cellfun(@(a) 1:numel(a), varargin, 'Uni', false);
idxs = cell(1, numel(varargin)); 
[idxs{:}] = ndgrid(nel{end:-1:1});
assert(numel(idxs{1}) == prod(nel_num));
idxs = cellfun(@(a) reshape(a, [], 1), idxs, 'Uni', false);
idxs = cell2mat(idxs(end:-1:1));

if isempty(getenv('SGE_TASK_FIRST')), setenv('SGE_TASK_FIRST', '1'); end;
if ~isempty(getenv('SGE_TASK_ID')) && ~isempty(getenv('SGE_TASK_LAST')) ...
    && ~isempty(getenv('SGE_TASK_FIRST'))
  task_last = str2double(getenv('SGE_TASK_LAST'));
  task_first = str2double(getenv('SGE_TASK_FIRST'));
  % Make sure it's one-indexed
  task_id = str2double(getenv('SGE_TASK_ID')) - task_first + 1;
  num_tasks = task_last - task_first + 1;
  task_sz = ceil(size(idxs, 1) / num_tasks);
  tasks_sel = (task_id - 1)*task_sz + 1 : min(size(idxs, 1), task_id*task_sz);
  fprintf('SGE JOB: %d:%d:%d [%d tasks %d/worker] : Sel [%d ... %d]\n', ...
    task_first, task_id, task_last, ...
    size(idxs, 1), task_sz, ...
    min(tasks_sel), max(tasks_sel));
  idxs = idxs(tasks_sel, :);
end

end

