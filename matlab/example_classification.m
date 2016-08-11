%% Example how to compute the classification benchmarks

setup();
imdb = hpatches_dataset();
methods = simple_descriptors();

classif_benchmark_path = fullfile('..', 'benchmarks', 'classification', ...
  'classification_pos_easy.txt');
classif_labels_path = fullfile('..', 'benchmarks', 'matching', ...
  'example_small.labels');

%% Compute the classification task

classif_get_results_path = @(method) fullfile('..', 'results', 'classification', ...
  'classification_pos_easy', [method.name, '.results']);

for mi = 1:numel(methods)
  res_path = classif_get_results_path(methods(mi));
  classification_compute(imdb, classif_benchmark_path, methods(mi).fun, ...
    res_path, 'cacheName', methods(mi).name);
end

%% Evaluate the results

classif_scores = cell(1, numel(methods));
for mi = 1:numel(methods)
  classif_scores{mi} = classification_eval(classif_benchmark_path, classif_labels_path, ...
    classif_get_results_path(methods(mi)));
end

%% Print the results

fprintf('Classification results: \n');
for mi = 1:numel(methods)
  fprintf('%s: %.2f auc.\n', methods(mi).name, classif_scores{mi}.auc);
end

%% Plot the ROCs

figure(1); clf;
colors = lines(numel(methods));
for mi = 1:numel(methods)
  plot(classif_scores{mi}.fpr, classif_scores{mi}.tpr, 'LineWidth', 2, ...
    'Color', colors(mi, :));
  hold on;
end
legend({methods.name});
xlabel('False positive rate'); ylabel('True positive rate');