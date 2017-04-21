function desc = meanstd(patches)

patches = single(squeeze(patches));
meanVal = reshape(mean(mean(patches, 1), 2), 1, []);
patchSz = [size(patches, 1), size(patches, 2)];
stdVal = std(reshape(single(patches), prod(patchSz(:)), []), 0, 1);
desc = [meanVal; stdVal];

end