function out = pick(res, tasks, names, cname, varargin)
opts.normname = [];
opts = vl_argparse(opts, varargin);

if ~iscell(names), names = {names}; end;

out = zeros(numel(tasks), numel(names));
for ti = 1:numel(tasks)
  filter = tasks(ti).filter;
  tsel = utls.filtertable(res, filter);
  for ni = 1:numel(names)
    nsel = ismember(res.descriptor, names{ni});
    if ~isempty(opts.normname)
      nsel = nsel & (ismember(res.norm_type, opts.normname{ni}) ...
        | ismember(strrep(res.norm_type, '.', '_'), opts.normname{ni}));
    end
    sel = find(tsel & nsel);
    if numel(sel) ~= 1
      error('%s Not found.', names{ni});
    end
    out(ti, ni) = res.(cname)(sel);
  end
end

end