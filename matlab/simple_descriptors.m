function methods = example_descriptors()
% Set of example descriptors

methods = {};
methods{end+1}.name = 'meanstd';
methods{end}.fun = @desc_patch_meanstd;

methods{end+1}.name = 'resize_4';
methods{end}.fun = @(varargin) desc_patch_resize(4, varargin{:});

methods{end+1}.name = 'surf';
methods{end}.fun = @desc_patch_matlab;

methods = cell2mat(methods);

end