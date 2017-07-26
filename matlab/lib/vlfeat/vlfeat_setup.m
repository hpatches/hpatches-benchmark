function vlfeat_setup( )
%VLFEAT_SETUP Setup and provision VLFeat library
assert(exist('hb_path', 'file') == 2, 'HB not found.');

vlf_dir = fullfile(hb_path, 'matlab', 'lib', 'vlfeat');
utls.provision(fullfile(vlf_dir, 'vlfeat.url'), vlf_dir, true);
vlf_dist_dir = dir(fullfile(vlf_dir, 'vlfeat*'));
vlf_dist_dir = vlf_dist_dir([vlf_dist_dir.isdir]);
run(fullfile(vlf_dir, vlf_dist_dir(1).name, 'toolbox', 'vl_setup.m'));

end

