%% Example how to compute the classification benchmarks

setup();
imdb = hpatches_dataset();
methods = simple_descriptors();
classif_task_name = 'train_example';

classif_pos_path = fullfile('..', 'benchmarks', 'classification', ...
  [classif_task_name, '_pos.pairs']);
classif_neg_path = fullfile('..', 'benchmarks', 'classification', ...
  [classif_task_name, '_neg.pairs']);

%% Compute the task

classif_get_results_path = @(method, label) fullfile('..', 'results', ...
  'classification', method.name, [classif_task_name, '_', label, '.results']);

for mi = 1:numel(methods)
  res_path = classif_get_results_path(methods(mi), 'pos');
  classification_compute(imdb, classif_pos_path, methods(mi).fun, ...
    res_path, 'cacheName', methods(mi).name);
  
  res_path = classif_get_results_path(methods(mi), 'neg');
  classification_compute(imdb, classif_neg_path, methods(mi).fun, ...
    res_path, 'cacheName', methods(mi).name);
end

%% Evaluate the results

classif_scores = cell(1, numel(methods));
for mi = 1:numel(methods)
  classif_scores{mi}.balanced = classification_eval(...
    classif_get_results_path(methods(mi), 'pos'), ...
    classif_get_results_path(methods(mi), 'neg'), 'balanced', true);
  classif_scores{mi}.imbalanced = classification_eval(...
    classif_get_results_path(methods(mi), 'pos'), ...
    classif_get_results_path(methods(mi), 'neg'), 'balanced', false);
end
classif_scores = cell2mat(classif_scores);

%% Print the results

fprintf('Classification results: \n');
for mi = 1:numel(methods)
  fprintf('% 10s: Balanced AUC %.2f  Imbalanced AP %.2f.\n', methods(mi).name, ...
    classif_scores(mi).balanced.auc, classif_scores(mi).imbalanced.ap);
end

%% Plot the ROCs

figure(1); clf;
colors = lines(numel(methods));
plot([0, 1], [0, 1], 'r--', 'LineWidth', 1); hold on;
for mi = 1:numel(methods)
  plot(1 - classif_scores(mi).balanced.tnr, classif_scores(mi).balanced.tpr, ...
    'LineWidth', 2, 'Color', colors(mi, :));
end
legend({'Chance', methods.name}, 'Location', 'SouthEast');
xlabel('False positive rate'); ylabel('True positive rate');
grid on;

%% Plot the PR curves

figure(2); clf;
pos_neg_ratio = classif_scores(1).imbalanced.numpos ./ ...
  (classif_scores(1).imbalanced.numpos + classif_scores(1).imbalanced.numneg);
plot([0, 1], [pos_neg_ratio, pos_neg_ratio], 'r--', 'LineWidth', 1); hold on;
for mi = 1:numel(methods)
  plot(classif_scores(mi).imbalanced.recall, ...
    classif_scores(mi).imbalanced.precision, ...
    'LineWidth', 2, 'Color', colors(mi, :));
end
legend({'Chance', methods.name}, 'Location', 'SouthEast');
xlabel('Recall'); ylabel('Precision');
grid on;