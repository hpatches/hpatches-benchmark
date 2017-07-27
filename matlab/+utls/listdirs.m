function dirs = listdirs(path)
assert(isdir(path), sprintf('%s not a directory.', path));
dirs = dir(path);
is_valid = [dirs.isdir] & arrayfun(@(d) d.name(1)~='.', dirs)';
dirs = {dirs.name};
dirs = dirs(is_valid);
end
