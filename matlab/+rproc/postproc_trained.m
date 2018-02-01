function table = postproc_trained(table, varargin)

nrows = size(table, 1);
table.trainsplit = cell(nrows, 1);
status = utls.textprogressbar(nrows, 'updatestep', 1, ...
  'startmsg', 'Processing results');
for nri = 1:nrows
  descriptor = table{nri, 'descriptor'}{1};
  
  if contains(descriptor, '-train-')
    split = strsplit(descriptor, '-');
    descriptor = split{1};
    split = split{end};
    switch split
      case 'illum'
        assert(strcmp('view', table.split{nri}));
      case 'view'
        assert(strcmp('illum', table.split{nri}));
      otherwise
        assert(strcmp(split, table.split{nri}));
    end
    table.descriptor{nri} = descriptor;
    table.trainsplit{nri} = split;
  end
  status(nri);
end

end