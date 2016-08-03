function desc = desc_patch_resize(numbins, signature, patches)

patches = single(squeeze(patches));
meanVal = reshape(mean(mean(patches, 1), 2), 1, 1, []);
stdVal = sqrt(reshape(var(var(patches, 0, 1), 0, 2), 1, 1, []));
patches = bsxfun(@rdivide, bsxfun(@minus, patches, meanVal), stdVal);

desc = zeros(numbins^2, size(patches, 3), 'single');
for pi = 1:size(patches, 3)
  patch = imresize(patches(:,:,pi), [numbins, numbins], 'Antialiasing', false);
  desc(:, pi) = patch(:);
end

end