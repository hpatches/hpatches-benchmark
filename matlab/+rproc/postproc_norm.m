function table = postproc_norm(table, varargin)
opts.embedNormSplit = false;
opts = vl_argparse(opts, varargin);

nrows = size(table, 1);
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
  end
  if opts.embedNormSplit
    table.descriptor(nri) = {[descriptor '-train-' split]};
  else
    table.descriptor(nri) = {descriptor};
    table.norm_split(nri) = {split};
  end
  table.norm_type(nri) = {norm};
end

end