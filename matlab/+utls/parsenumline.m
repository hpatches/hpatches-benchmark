function data = parsenumline(line, isint)
if nargin < 2, isint = false; end;
data = strsplit(line, ',');
data = cellfun(@str2double, data);
assert(all(~isnan(data)), 'Invalid data...');
if isint
  assert(all(mod(data, 1) == 0), 'Data are not integers.');
end
end