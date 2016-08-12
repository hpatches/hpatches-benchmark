# Image Matching Benchmark

This benchmark evaluates performance of a feature descriptor in ranking task for image-to-image matching. It measures the performance of the nearest neighbor classifier in a similar way as [1].

Measured value is a mean average precision (mAP) computed over all image matching tasks defined in the benchmark files. The benchmark tasks are defined in files:

`test_easy_illum.benchmark` contains pairs of images with easy affine jitters between the corresponding patches from scenes where the illumination changes.

`test_easy_viewpoint.benchmark` contains pairs of images with easy affine jitter between the patches from scenes where the viewpoint changes.

Similarly, `test_hard_illum.benchmark` and `test_hard_viewpoint.benchmark` contains patches with harder affine jitter between the patches.

The format of the benchmark files is:
``` bash
im_a,im_b  # First image pair
im_x,im_y
...
```
Where each line specifies the signatures of a pair of patch-images among which the descriptors should be matched.

# Evaluation
For each patch-image pair, use your descriptor to compute the feature vector for all patches of the images. Then use your required distance measure (e.g. L1 or L2) to find the two closest patches from `im_b` from the `im_a` together with their distances.

You can generate the results files with MATLAB scripts `../matching_compute.m` and compute the PR curves and the AP with `../matching_eval.m`.

For a descriptor `mega_matcher`, your results will be stored in files:
``` bash
../results/matching/mega_matches/test_easy_illum.results
../results/matching/mega_matches/test_easy_viewpoint.results
../results/matching/mega_matches/test_hard_illum.results
../results/matching/mega_matches/test_hard_viewpoint.results
```

To simplify the notations a function ``nn(a, B, n)`` signifies the *index* of the nth nearest neighbor of a patch $a$ from a patch-image $B$ (in both cases expressed with their signatures). ``|patch_a, patch_b|`` refers to a distance between two descriptor patches.
The format of the results file is a name of the patch-image pair followed by 4 lines.:
```
im_a,im_b
nn(im_a.0, im_b, 1),                     nn(im_a.1, im_b, 1), ...
|im_a.0, im_b.nn(image_a.0, im_b, 1)|,  |im_a.1, im_b.nn(image_a.0, im_b, 1)|, ...
nn(im_a.0, im_b, 2),                     nn(im_a.1, im_b, 2), ...
|im_a.0, im_b.nn(image_a.0, im_b, 2)|,  ...
im_x,im_y
...
```
i.e. the list of indexes of the first nearest neighbors for each `im_a` patch followed by their distance. Then, this follows with a list of the second nearest neighbors and their distances.

If a sequence `s_boring` contains only two patches,
and the nearest neighbors of `s_boring.a.0` are `s_boring.b.1, s_boring.b.0` with distance 12.3 and 14.2 respectively, and `s_boring.b.0, s_boring.b.1` are the closest patches to the `s_boring.a.1` the results file would look like as following:
```
s_boring.a,s_boring.b
1, 0
12.3, 7.5
0, 1
14.2, 27.4
```

# References
[1] K. Mikolajczyk and C. Schmid. A performance evaluation of local descriptors. In IEEE TPAMI 2005.
