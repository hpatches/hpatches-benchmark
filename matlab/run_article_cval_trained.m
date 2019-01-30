% Recompute all scores for all descriptors.
% Requires approximately at least 64GB RAM, unless `num_neg` is decreased.

descs = {};
descs{end+1} = struct('name', 'meanstd', 'split', {{'a', 'b', 'c', 'view', 'illum', 'full'}}); 
descs{end+1} = struct('name', 'sift', 'split', {{'a', 'b', 'c', 'view', 'illum', 'full'}}); 
descs{end+1} = struct('name', 'HardNetLib+', 'split', {{'a', 'b', 'c', 'view', 'illum', 'full'}}); 
descs{end+1} = struct('name', 'tfeat-n-lib', 'split', {{'a', 'b', 'c', 'view', 'illum', 'full'}}); 

descs{end+1} = struct('name', 'hp-train-a', 'split', {{'b', 'c'}}); 
descs{end+1} = struct('name', 'hp-train-b', 'split', {{'a', 'c'}}); 
descs{end+1} = struct('name', 'hp-train-c', 'split', {{'a', 'b'}});
descs{end+1} = struct('name', 'hp-train-illum', 'split', 'view'); 
descs{end+1} = struct('name', 'hp-train-view', 'split', 'illum'); 

descs{end+1} = struct('name', 'tfeat-n-train-a', 'split', {{'b', 'c'}}); 
descs{end+1} = struct('name', 'tfeat-n-train-b', 'split', {{'a', 'c'}}); 
descs{end+1} = struct('name', 'tfeat-n-train-c', 'split', {{'a', 'b'}}); 
descs{end+1} = struct('name', 'tfeat-n-train-illum', 'split', 'view'); 
descs{end+1} = struct('name', 'tfeat-n-train-view', 'split', 'illum'); 
descs = cell2mat(descs);

global_args = {'num_neg', inf, 'numtype', 'double', ...
  'scoresroot', fullfile(hb_path, 'matlab', 'scores', 'scores_all_cval_trained')};

%%
args = {};
for di = 1:numel(descs)
    args{end+1} = [{descs(di).name, 'norm', false, ...
      'split', descs(di).split}, global_args];
end
fprintf('%d tasks.\n', numel(args));

%%
sel = utls.parallelise(1:numel(args));
parfor ai = 1:size(sel, 1)
  hb('all', args{sel(ai)}{:});
end
