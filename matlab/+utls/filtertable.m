function sel = filtertable( table, filter )

fnames = fieldnames(filter);
sel = true(size(table, 1), 1);

for fi = 1:numel(fnames)
  fname = fnames{fi};
  fvalue = filter.(fname);
  sel = sel & ismember(table.(fname), fvalue);
end

end

