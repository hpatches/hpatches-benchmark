function path = get_dataset( varargin )
%GET_DATASET Provision the HPatches dataset
%  Downloads the HPatches dataset to `<hb_root>/data/hpatches_v1.1`.

% Copyright (C) 2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.urlFile = fullfile(hb_path, 'data', 'hpatches_v1.1.url');
opts.tgtDir = fullfile(hb_path, 'data', 'hpatches_v1.1');
opts = vl_argparse(varargin);

provision(opts.urlFile, opts.tgtDir);
path = opts.tgtDir;
end

