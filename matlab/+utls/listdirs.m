function dirs = listdirs(path)
dirs = dir(path);
is_valid = [dirs.isdir] & arrayfun(@(d) d.name(1)~='.', dirs)';
dirs = {dirs.name};
dirs = dirs(is_valid);
end