function bar_plot( res, column, tasks, dets, varargin)

opts.legend = true;
opts.legendArgs = {'Location', 'SouthOutside', 'Interpreter', 'none', 'Orientation', 'Horizontal'};
opts.sort = true;
opts.detnames = {dets.name};
opts.multiplier = 100;
opts = vl_argparse(opts, varargin);

if isfield(dets, 'normname')
  normnames = {dets.normname};
else
  normnames = [];
end
data = rproc.pick(res, tasks, {dets.name}, column, 'normname', normnames);
data = data .* opts.multiplier;
avg = mean(data, 1);
if opts.sort
  [avg, order] = sort(avg, 'ascend');
  dets = dets(order);
  data = data(:, order);
  opts.detnames = opts.detnames(order);
end

for ni = numel(dets):-1:1
  position = ni;
  barh(position, avg(ni), 'FaceColor', dets(ni).color, dets(ni).bararg{:});
  hold on;
  
  text(101, position, sprintf('%0.2f%%', avg(ni)),...
    'HorizontalAlignment', 'left',...
    'VerticalAlignment', 'middle');
  
  li = zeros(1, numel(tasks));
  for ti = 1:numel(tasks)
    li(ti) = plot(data(ti, ni), position, '.', tasks(ti).style{:});
  end
end
set(gca,'Ydir','reverse')
set(gca, 'YTick', 1:numel(dets));
set(gca, 'TickLabelInterpreter', 'none');
set(gca, 'YTickLabel', opts.detnames);

if opts.legend
  legend(li, tasks, opts.legendArgs{:});
end
axis tight;
set(gca, 'XLim', [0, 100]);
grid on;
end

