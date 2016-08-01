function desc = desc_patch_matlab( patches, varargin )
opts.method = 'SURF';
opts.resolution = 15;
opts.builtinMag = 6;
opts.SURFSize = 128;
opts = vl_argparse(opts, varargin);

patches = squeeze(patches);
is_uint = isa(patches, 'uint8');
if is_uint, patches = single(patches) ./ 255; end

psz = opts.resolution * 2 + 1;
frm = SURFPoints((psz ./ 2 + 0.5) * ones(1, 2), 'Scale', psz ./ 2 ./ opts.builtinMag);
desc = [];
for pi = 1:size(patches, 3)
  p = imresize(patches(:,:,pi), [psz, psz]);
  [d, ~] = extractFeatures(p, frm, 'Upright', true, 'Method', opts.method, ...
    'SURFSize', opts.SURFSize);
  assert(~isempty(d));
  if isempty(desc), desc = zeros(numel(d), size(patches, 3), 'single'); end
  desc(:, pi) = d;
end

end

