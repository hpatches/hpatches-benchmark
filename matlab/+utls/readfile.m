function data = readfile(path, varargin)
opts.asString = false;
opts = vl_argparse(opts, varargin);

assert(exist(path, 'file') == 2, 'File %s does not exist.', path);

fd = fopen(path, 'r');
data = textscan(fd, '%s', 'delimiter', '\n'); 
fclose(fd);

data = data{1};
data = cellfun(@strtrim, data, 'UniformOutput', false);
isNonAscii = cellfun(@(s) all(s < 128), data);
assert(all(isNonAscii), 'File %s contains non ascii characters.', path);
if opts.asString
  data = strjoin(data, '\n');
end
