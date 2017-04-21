function desc = matlabFeature( patches, varargin )
opts.method = 'SURF';
opts.resolution = 32;
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
  p = patches(:,:,pi);
  if any(size(p) ~= [psz, psz]), p = imresize(p, [psz, psz]); end
  [d, ~] = extractFeatures(p, frm, 'Upright', true, 'Method', opts.method, ...
    'SURFSize', opts.SURFSize);
  assert(~isempty(d));
  if isempty(desc), desc = zeros(numel(d), size(patches, 3), 'single'); end
  desc(:, pi) = d;
end

end

