function filess = listfiles(path, skip_ext)
if nargin < 2, skip_ext = false; end
if contains(path, '*')
  if ~isdir(fileparts(path)), error('%s is not a directory.', path); end
else
  if ~isdir(path), error('%s is not a directory.', path); end;
end
filess = dir(path);
is_valid = ~[filess.isdir] & arrayfun(@(d) d.name(1)~='.', filess)';
filess = {filess.name};
filess = filess(is_valid);
if skip_ext
  for fi = 1:numel(filess)
    [~, filess{fi}, ~] = fileparts(filess{fi});
  end
end
end