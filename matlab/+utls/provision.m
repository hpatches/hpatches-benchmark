function downloaded = provision( url_file, tgt_dir, override )
if nargin < 3, override = false; end;
downloaded = false;
if ~exist(url_file, 'file')
  error('Unable to find the URL file %s.', url_file);
end;
[~, url_file_nm] = fileparts(url_file);
done_file = fullfile(tgt_dir, ['.', url_file_nm, '.done']);
if ~exist(tgt_dir, 'dir'), mkdir(tgt_dir); end
if exist(done_file, 'file') && ~override, return; end;
url = utls.readfile(url_file);
for ui = 1:numel(url)
  unpack(url{ui}, tgt_dir);
end
downloaded = true;
create_done(done_file);
end

function create_done(done_file)
f = fopen(done_file, 'w'); fclose(f);
fprintf('To reprovision, delete %s.\n', done_file);
end

function unpack(url, tgt_dir)
[~,~,ext] = fileparts(url);
fprintf(isdeployed+1, ...
  'Downloading %s -> %s, \n\tthis may take a while...\n',...
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
