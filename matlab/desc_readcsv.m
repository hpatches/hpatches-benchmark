function desc = desc_readcsv( imdb, datapath, signature, patches )

[sequence, im, patch] = imdb.encodeSignature(signature);
csvpath = fullfile(datapath, sequence, [im '.csv']);
if ~exist(csvpath, 'file')
  error('CSV file %s not found.', csvpath);
end
desc = csvread(csvpath);
if ~isnan(patch)
  desc = desc(:, patch);
end