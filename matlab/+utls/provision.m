function downloaded = provision( url_file, tgt_dir, override )
if nargin < 3, override = false; end;
downloaded = false;
if ~exist(url_file, 'file')
  error('Unable to find the URL file %s.', url_file);
end;
[~, url_file_nm] = fileparts(url_file);
done_file = fullfile(tgt_dir, ['.', url_file_nm, '.done']);
if exist(tgt_dir, 'dir')
  if ~exist(done_file, 'file')
    if ~override
      res = input('Target directory %s already exist. Continue? [Y/N] Y ', ...
        's');
    end
    if override || ismember(lower(res), {'n', 'no'})
      create_done(done_file);
      return;
    end
  end
else
  mkdir(tgt_dir);
end
if exist(done_file, 'file'), return; end;
url = utls.readfile(url_file);
for ui = 1:numel(url)
  p_untar(url{ui}, tgt_dir);
end
downloaded = true;
create_done(done_file);
end

function create_done(done_file)
f = fopen(done_file, 'w'); fclose(f);
fprintf('To reprovision, delete %s.\n', done_file);
end

function p_untar(url, tgt_dir)
[~, wget_p] = system('which wget');
if exist(strtrim(wget_p), 'file');
  [~, fname, ext] = fileparts(url);
  tar_file = fullfile(tgt_dir, [fname, ext]);
  if ~exist(tar_file, 'file')
    fprintf(isdeployed+1, 'Downloading %s -> %s.\n', url, tar_file);
    ret = system(sprintf('wget %s -O %s', url, tar_file));
    if ret ~= 0
      fprintf(isdeployed+1, 'wget failed.');
      delete(tar_file);
    end;
  end
  if exist(tar_file, 'file')
    fprintf(isdeployed+1, 'Unpacking %s -> %s. This may take a while...\n', ...
      tar_file, tgt_dir);
    untar(tar_file, tgt_dir);
  else
    m_untar(url, tgt_dir);
  end
else
  m_untar(url, tgt_dir);
end
end

function m_untar(url, tgt_dir)
fprintf(isdeployed+1, ...
  'Downloading %s -> %s using MATLAB, this may take a while...\n',...
  url, tgt_dir);
untar(url, tgt_dir);
end