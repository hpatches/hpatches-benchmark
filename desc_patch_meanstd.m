function desc = desc_patch_meanstd(signature, patches)

patches = single(squeeze(patches));
meanVal = reshape(mean(mean(patches, 1), 2), 1, []);
stdVal = sqrt(reshape(var(var(patches, 0, 1), 0, 2), 1, []));
desc = [meanVal; stdVal];

end