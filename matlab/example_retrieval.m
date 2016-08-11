%% Example how to compute the retrieval benchmarks

setup();
imdb = hpatches_dataset();
methods = simple_descriptors();

retr_benchmark_path = fullfile('..', 'benchmarks', 'retrieval', ...
  'example_small.benchmark');
retr_labels_path = fullfile('..', 'benchmarks', 'retrieval', ...
  'example_small.labels');

%% Compute the classification task

retr_get_results_path = @(method) fullfile('..', 'results', 'retrieval', ...
  'example_small', [method.name, '.results']);

for mi = 1:numel(methods)
  res_path = retr_get_results_path(methods(mi));
  retrieval_compute(imdb, retr_benchmark_path, methods(mi).fun, ...
    res_path, 'cacheName', methods(mi).name);
end

%% Evaluate the results

retr_scores = cell(1, numel(methods));
for mi = 1:numel(methods)
  retr_scores{mi} = retrieval_eval(retr_benchmark_path, retr_labels_path, ...
    retr_get_results_path(methods(mi)));
end
retr_scores_chance = retrieval_eval_chance(imdb, retr_labels_path);

%% Print the results

fprintf('Retrieval results: \n');
fprintf('% 10s: Image retr %.2f mAP   Patch retr. %.2f mAP.\n', 'Chance', ...
    mean(retr_scores_chance.image_retr_ap(:))*100, ...
    mean(retr_scores_chance.patch_retr_ap(:))*100);
for mi = 1:numel(methods)
  fprintf('% 10s: Image retr %.2f mAP   Patch retr. %.2f mAP.\n', methods(mi).name, ...
    mean(retr_scores{mi}.image_retr_ap(:))*100, ...
    mean(retr_scores{mi}.patch_retr_ap(:))*100);
end
