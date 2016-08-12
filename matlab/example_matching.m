%% Example how to compute the mathcing benchmarks

setup();
imdb = hpatches_dataset();
methods = simple_descriptors();
matching_task_name = 'train_example';

matching_benchmark_path = fullfile('..', 'benchmarks', 'matching', ...
  [matching_task_name, '.benchmark']);
matching_labels_path = fullfile('..', 'benchmarks', 'matching', ...
  [matching_task_name, '.labels']);

%% Compute the task

matching_get_results_path = @(method) fullfile('..', 'results', 'matching', ...
  matching_task_name, [method.name, '.results']);

for mi = 1:numel(methods)
  res_path = matching_get_results_path(methods(mi));
  matching_compute(imdb, matching_benchmark_path, methods(mi).fun, ...
    res_path, 'cacheName', methods(mi).name);
end

%% Evaluate the results

matching_scores = cell(numel(methods), 1);
for mi = 1:numel(methods)
  matching_scores{mi} = matching_eval(matching_benchmark_path, ...
    matching_labels_path, matching_get_results_path(methods(mi)));
end
matching_scores = cell2mat(matching_scores);

%% Print the results

fprintf('Matching results: \n');
for mi = 1:numel(methods)
  fprintf('% 10s: %.2f mAP.\n', methods(mi).name, ...
    mean([matching_scores(mi, :).ap])*100);
end

%% Plot the PR curves for a single matching task

taski = 1;
figure(1); clf; colors = lines(numel(methods));
for mi = 1:numel(methods)
  plot(matching_scores(mi, taski).recall, ...
    matching_scores(mi, taski).precision, ...
    'LineWidth', 2, 'Color', colors(mi, :));
  hold on;
end
legend({methods.name});  title(matching_scores(1, taski).name, ...
  'Interpreter', 'none');
xlabel('Recall'); ylabel('Precision'); grid on;
