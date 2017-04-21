function table = postproc_norm(table)

nrows = size(table, 1);

for nri = 1:nrows
  split = 'none';
  norm = 'none';
  descriptor = table{nri, 'descriptor'}{1};
  pos = strfind(descriptor, 'nsplit');
  if ~isempty(pos)
    split = descriptor(pos+7);
    norm = descriptor(pos+9:end);
    descriptor = descriptor(1:pos-2);
  end
  table.descriptor(nri) = {descriptor};
  table.norm_split(nri) = {split};
  table.norm_type(nri) = {norm};
end

end