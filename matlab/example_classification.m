%% Example how to compute the matching benchmarks
% Load the imdb
setup();
imdb = hpatches_dataset();

%% Compute the matching task for some simple descriptors

matching_task = fullfile('..', 'benchmarks', 'classification', 'classification_pos_easy.txt');
results_path = fullfile('..', 'results', 'classification', 'classification_pos_easy');

methods = {};
methods{end+1}.name = 'meanstd';
methods{end}.fun = @desc_patch_meanstd;

methods{end+1}.name = 'resize_4';
methods{end}.fun = @(varargin) desc_patch_resize(4, varargin{:});

methods{end+1}.name = 'surf';
methods{end}.fun = @desc_patch_matlab;

methods = cell2mat(methods);


for mi = 1:numel(methods)
  res_path = fullfile(results_path, [methods(mi).name, '.results']);
  matching_compute(imdb, matching_task, methods(mi).fun, res_path, ...
    'cacheName', methods(mi).name);
end


%% Evaluate the results

labels_file = fullfile('..', 'benchmarks', 'matching', 'example_small.labels');
results_desc_meanstd = matching_eval(matching_task, labels_file, desc_meanstd_p);
results_desc_resize = matching_eval(matching_task, labels_file, desc_resize_p);
results_desc_surf = matching_eval(matching_task, labels_file, desc_surf_p);

fprintf('MeanStd mAP: %.2f\nResize mAP: %.2f\nSURF mAP: %.2f\n', ...
  mean([results_desc_meanstd.ap])*100, ...
  mean([results_desc_resize.ap])*100, ...
  mean([results_desc_surf.ap])*100);