function kde_setup( )
%VLFEAT_SETUP Setup and provision VLFeat library
assert(exist('hb_path', 'file') == 2, 'HB not found.');

if exist('kde.m', 'file') == 2, return; end;

kde_dir = fullfile(hb_path, 'matlab', 'lib', 'kde');
utls.provision(fullfile(kde_dir, 'kde.url'), kde_dir);
kde_dist_dir = fullfile(kde_dir, 'kde-master');
addpath(fullfile(kde_dist_dir, 'kde'));
addpath(fullfile(kde_dist_dir, 'helpers'));
end

