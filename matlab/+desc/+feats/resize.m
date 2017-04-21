function x = resize(patches, varargin)
opts.numbins = 4;
opts = vl_argparse(opts, varargin);

patches = single(squeeze(patches));
meanVal = reshape(mean(mean(patches, 1), 2), 1, 1, []);
patchSz = [size(patches, 1), size(patches, 2)];
stdVal = reshape(std(reshape(single(patches), prod(patchSz(:)), []), 0, 1), 1, 1, []);
patches = bsxfun(@rdivide, bsxfun(@minus, patches, meanVal), stdVal);

x = zeros(opts.numbins^2, size(patches, 3), 'single');
for pi = 1:size(patches, 3)
  patch = imresize(patches(:,:,pi), [opts.numbins, opts.numbins], ...
    'Antialiasing', false);
  x(:, pi) = patch(:);
end
% L2 norm
l = sqrt(sum(x.^2, 1));
x = bsxfun(@rdivide, x, l);

x(isnan(x)) = 0; x(isinf(x)) = 0;

end
