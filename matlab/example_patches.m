%% Example script how to load patches
% Load the imdb

imdb = hpatches_dataset();

%% Show few clusters
sequence = 'v_underground';
sel_patches = 1:10;

% Retrieved patches are a tensor of size:
%  [H x W x 1 x NUM_PATHCES x NUM_IMAGES]
ref_patches = imdb.getPatches(sequence, 'ref', sel_patches);
hard_patches = imdb.getPatches(sequence, 7:11, sel_patches);
patches = cat(5, ref_patches, hard_patches);

% Create a mosaic and show the patches
mosaic = vl_imarray(reshape(patches, 65, 65, []), ...
  'layout', [ size(patches, 5), size(patches, 4)]);
figure(1); clf; imshow(mosaic);