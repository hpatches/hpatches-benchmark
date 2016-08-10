function res = classification_eval( benchpath, labelspath, resultspath )
% Read the benchmark file
benchmarks = utls.readfile(benchpath);
% Read the labels file
labels = utls.readfile(labelspath);
assert(numel(labels) == numel(benchmarks), 'Invalid labels file.');
labels = cellfun(@num2double, labels);
assert(all(~isnan(labels)), 'Invalid results - unable to read the numeric values.');

% Read the results file
results = utls.readfile(resultspath);
assert(numel(results) == numel(benchmarks), 'Invalid results file.');
results = cellfun(@num2double, results);
assert(all(~isnan(results)), 'Invalid results - unable to read the numeric values.');

[tpr, tnr, res] = vl_roc(labels*2 - 1, -results);
res.tpr = tpr; res.tnr = tnr;
end
