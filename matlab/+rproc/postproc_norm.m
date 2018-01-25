function table = postproc_norm(table, varargin)
opts.embedNormSplit = false;
opts.renameNorm = false;
opts = vl_argparse(opts, varargin);

nrows = size(table, 1);
status = utls.textprogressbar(nrows, 'updatestep', 1, ...
  'startmsg', 'Processing results');
for nri = 1:nrows
  split = 'none';
  norm = 'none';
  descriptor = table{nri, 'descriptor'}{1};
  pos = strfind(descriptor, 'nsplit');
  if ~isempty(pos)
    split = descriptor(pos+7);
    norm = descriptor(pos+9:end);
    if isempty(norm), norm = 'none'; end
    descriptor = descriptor(1:pos-2);
    if opts.renameNorm
      descriptor = [descriptor '-norm'];
    end
  end
  if opts.embedNormSplit
    if contains(descriptor, ['-train-' split])
      table.descriptor(nri) = {descriptor};
    else
      table.descriptor(nri) = {[descriptor '-train-' split]};
    end
  else
    table.descriptor(nri) = {descriptor};
    table.norm_split(nri) = {split};
  end
  table.norm_type(nri) = {norm};
  status(nri);
end

end