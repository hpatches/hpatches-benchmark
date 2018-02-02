function patches = load_phototourism(impath, varargin)
opts.patchSize = [64, 64];
opts = vl_argparse(opts, varargin);

patches = imread(impath);
npatches = [size(patches, 1), size(patches, 2)] ./ opts.patchSize;
assert(all(mod(npatches, 1) == 0), 'Invalid patch file.');
patches = mat2cell(patches, opts.patchSize(1)*ones(1, npatches(1)), ...
  opts.patchSize(2)*ones(1, npatches(2)));
patches = patches'; % MATLAB goes rows first, patches are column first
patches = patches(:);
patches = permute(patches, [2, 3, 4, 1]);
patches = cell2mat(patches);

% Remove the completely empty patches
patchsum = squeeze(sum(sum(patches, 1), 2));
isvalid = patchsum > 0;
if sum(isvalid) ~= numel(isvalid)
  patches = patches(:,:,:,isvalid);
end

end