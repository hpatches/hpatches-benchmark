%% Example script how to load patches

imdb = hpatches_dataset();

sel_patches = 1:10; sel_rows = 1:6;
patches = imdb.getPatches('v_underground', sel_rows, sel_patches);
