function [ splits ] = splitsdb( varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

opts.addValSplits = {};
opts.numVal = 20;
opts.seed = 1;
opts = vl_argparse(opts, varargin);

splits = utls.parse_json(fullfile(hb_path, 'matlab', 'data', 'splits.json'));

if ~isempty(opts.addValSplits)
  q = RandStream('mt19937ar', 'Seed', opts.seed);
  if ~iscell(opts.addValSplits), opts.addValSplits = {opts.addValSplits}; end
  for si = 1:numel(opts.addValSplits)
    split = opts.addValSplits{si};
    if ~isfield(splits.(split), 'train')
      warning('Split % does not have train sequences', split);
    end
    seq = splits.(split).train;
    val_sel_i = randsample(q, numel(seq), opts.numVal);
    splits.(split).val = seq(val_sel_i);
    splits.(split).train = setdiff(splits.(split).train, splits.(split).val);
    assert(numel(unique([splits.(split).val, splits.(split).train])) == ...
      numel(splits.(split).train) + numel(splits.(split).val));
  end
end

end

