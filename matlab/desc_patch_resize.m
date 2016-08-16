function desc = desc_patch_resize(numbins, signature, patches)

patches = single(squeeze(patches));
meanVal = reshape(mean(mean(patches, 1), 2), 1, 1, []);
patchSz = [size(patches, 1), size(patches, 2)];
stdVal = reshape(std(reshape(single(patches), prod(patchSz(:)), []), 0, 1), 1, 1, []);
patches = bsxfun(@rdivide, bsxfun(@minus, patches, meanVal), stdVal);

desc = zeros(numbins^2, size(patches, 3), 'single');
for pi = 1:size(patches, 3)
  patch = imresize(patches(:,:,pi), [numbins, numbins], 'Antialiasing', false);
  desc(:, pi) = patch(:);
end

end