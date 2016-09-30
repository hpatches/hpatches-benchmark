function hb_test(varargin)

hb_setup();

opts.descname = 'meanstd';
opts.taskname = 'train_example*';
opts.commands = {'pack', 'checkdesc', 'computedesc', 'classification', ...
  'matching', 'retrieval', 'packdesc'};
opts = vl_argparse(opts, varargin);

hb('computedesc', opts.descname);

for cmi = 1:numel(opts.commands)
  hb(opts.commands{cmi}, opts.descname, opts.taskname, 'override', 'true');
end

end
