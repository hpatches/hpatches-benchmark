%% Example how to compute the matching benchmarks
% Load the imdb

imdb = hpatches_dataset();

%% Compute the retrieval task for some simple descriptors

retrieval_task = fullfile('..', 'data', 'hpatches', 'retrieval_easy_train_small.txt');

desc_meanstd_p = fullfile('data', 'retrieval_easy_train_small_desc_meanstd.txt');
retrieval_compute(imdb, retrieval_task, @desc_patch_meanstd, desc_meanstd_p, ...
  'cacheName', 'desc_meanstd');

desc_resize_p = fullfile('data', 'retrieval_easy_train_small_desc_resize.txt');
retrieval_compute(imdb, retrieval_task, @(varargin) desc_patch_resize(4, varargin{:}), desc_resize_p, ...
  'cacheName', 'desc_resize_4');

desc_surf_p = fullfile('data', 'retrieval_easy_train_small_desc_surf.txt');
retrieval_compute(imdb, retrieval_task, @desc_patch_matlab, desc_surf_p, ...
  'cacheName', 'desc_matlab_surf');

%% Evaluate the results

labels_file = fullfile('..', 'data', 'hpatches', 'retrieval_easy_train_small_labels.txt');
results_desc_meanstd = retrieval_eval(imdb, retrieval_task, labels_file, desc_meanstd_p);
results_desc_resize = retrieval_eval(imdb, retrieval_task, labels_file, desc_resize_p);
results_desc_surf = retrieval_eval(imdb, retrieval_task, labels_file, desc_surf_p);

fprintf('MeanStd mAP: %.2f\nResize mAP: %.2f\nSURF mAP: %.2f\n', ...
  mean([results_desc_meanstd.ap(:)])*100, ...
  mean([results_desc_resize.ap(:)])*100, ...
  mean([results_desc_surf.ap(:)])*100);