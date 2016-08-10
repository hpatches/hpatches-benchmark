%% Example how to compute the matching benchmarks
% Load the imdb
setup();
imdb = hpatches_dataset();

%% Compute the matching task for some simple descriptors

matching_task = fullfile('..', 'benchmarks', 'matching', 'example_small.benchmark');

desc_meanstd_p = fullfile('..', 'results', 'matching', 'example_small', 'desc_meanstd.results');
matching_compute(imdb, matching_task, @desc_patch_meanstd, desc_meanstd_p, ...
  'cacheName', 'desc_meanstd');

desc_resize_p = fullfile('..', 'results', 'matching', 'example_small', 'desc_resize.results');
matching_compute(imdb, matching_task, @(varargin) desc_patch_resize(4, varargin{:}), desc_resize_p, ...
  'cacheName', 'desc_resize_4');

desc_surf_p = fullfile('..', 'results', 'matching', 'example_small', 'desc_surf.results');
matching_compute(imdb, matching_task, @desc_patch_matlab, desc_surf_p, ...
  'cacheName', 'desc_matlab_surf');

%% Evaluate the results

labels_file = fullfile('..', 'benchmarks', 'matching', 'example_small.labels');
results_desc_meanstd = matching_eval(matching_task, labels_file, desc_meanstd_p);
results_desc_resize = matching_eval(matching_task, labels_file, desc_resize_p);
results_desc_surf = matching_eval(matching_task, labels_file, desc_surf_p);

fprintf('MeanStd mAP: %.2f\nResize mAP: %.2f\nSURF mAP: %.2f\n', ...
  mean([results_desc_meanstd.ap])*100, ...
  mean([results_desc_resize.ap])*100, ...
  mean([results_desc_surf.ap])*100);