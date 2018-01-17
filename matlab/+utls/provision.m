function downloaded = provision( url, tgt_dir, varargin )
p = inputParser;
addParameter(p, 'doneName', '.download.done', @isstr);
addParameter(p, 'override', false, @islogical);
addParameter(p, 'forceExt', '', @isstr);
parse(p, varargin{:}); opts = p.Results;

if exist(url, 'file'), url = fileread(url); end;
url = strtrim(url);
downloaded = false;
done_file = fullfile(tgt_dir, opts.doneName);
if ~exist(tgt_dir, 'dir'), mkdir(tgt_dir); end
if exist(done_file, 'file') && ~opts.override, return; end;
unpack(url, tgt_dir, opts);
downloaded = true;
create_done(done_file);
end

function create_done(done_file)
f = fopen(done_file, 'w'); fclose(f);
fprintf('To reprovision, delete %s.\n', done_file);
end

function unpack(url, tgt_dir, opts)
[~,~,ext] = fileparts(url);
if opts.forceExt, ext = opts.forceExt; end;
fprintf(isdeployed+1, ...
  'Downloading %s -> %s, this may take a while...\n',...
  url, tgt_dir);
switch ext
  case {'.tar', '.gz'}
    untar(url, tgt_dir);
  case '.zip'
    unzip(url, tgt_dir);
  otherwise
    error('Unknown archive %s', ext);
end
end