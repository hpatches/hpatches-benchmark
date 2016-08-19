# Image Matching Benchmark

The *Image Matching Benchmark* (IMB) evaluates the ability of a patch descriptor to match a patch in a reference image to its corresponding patch in a target image. It is called "image matching" because  matching is restricted to patches coming from a single target image at a time.

This problem is formulated as a ranking task: for each reference patch, all target patches are sorted by decreasing descriptor similarly to the reference patch and performance is measured by computing the average precision (AP) of the resulting rank list. The final performance is reported as the mean average precision (mAP) for all the reference patches. It is conceptually very similar to the nearest neighbor patch classifier evaluation explored in [1].

[TOC]

## Benchmark definitions

The benchmark is composed of a number of tasks, each defined by a corresponding `.benchmark` file. There are four such files:

```bash
> ls -1 benchmarks/matching/*benchmark
train_easy_illum.benchmark
train_easy_viewpoint.benchmark
train_hard_illum.benchmark
train_hard_viewpoint.benchmark
```

Once the test set will be made available, corresponding `test_*` files will also be delivered.

The corresponding tasks are as follows:

* `train_easy_illum.benchmark` contains pairs of images with easy affine jitters between the corresponding patches from scenes where the illumination changes.
* `train_easy_viewpoint.benchmark` contains pairs of images with easy affine jitter between the patches from scenes where the viewpoint changes.
* Similarly, `train_hard_illum.benchmark` and `train_hard_viewpoint.benchmark` contains patches with harder affine jitter between the patches.

### Benchmark file format

Each `*.benchmark` file is of the type:

```
im_a,im_b
im_x,im_y
...
```

where each line specifies a pair of patch-image among which the descriptors should be matched. [Recall](../../README.md#reading-patches) that patches in *HPatches* are organized in patch-images, each identified by a pair `SEQNAME.IMNAME`. 

For exxample, the content of `train_easy_illum` looks as follows:

```bash
> cat benchmarks/matching/train_easy_illum.benchmark
i_boutique.ref,i_boutique.e1
i_boutique.ref,i_boutique.e2
...
```

This means that all patches in `i_botique.ref` should be matched to all patches in `i_botique.e1`.


## Entering the benchmarks

Entering the benchmark is conceptually simple:

1. Identify all the image pairs to be matched.
2. Use your descriptor to compare each patch in the reference image (first image in the pair) to each patch in the target mage (second image in the pair). For this step, you can use your preferred distance measure (e.g. L1 or L2) or any other dissimilarity score.
3. Write the results of such comparisons to a ranked list.

In more detail, for each `*.benchmark` file, you need to write a corresponding `*.results` file. In order to allow comparing different descriptors, each file must be store in a descriptor-specific directory. So, if `my_desc` is the name of your descriptor, you need to write the four files:

```
results/matching/my_desc/test_easy_illum.results
results/matching/my_desc/test_easy_viewpoint.results
results/matching/my_desc/test_hard_illum.results
results/matching/my_desc/test_hard_viewpoint.results
```

### Result file format

A result file is organized as follows:

```
First image pair (reference,target)
  For each reference patch, the index of the corresponding nearest target patch
  Corresponding distances
  For each reference patch, the index of the corresponding 2-nd nearest target patch
  Corresponding distances
  ...
Second image pair (reference,target)
  For each reference patch, the index of the corresponding nearest target patch
  Corresponding distances
  ...
```

For example, the file `train_easy_illum.results` may look something like:

```bash
> cat results/my_desc/matching/train_easy_illum.results 
i_boutique.ref,i_boutique.e1
  732,          761,          154,          564, ...
  7.174843e+00, 1.438751e+01, 6.510703e+00, 1.225562e+01, ...
  0,            828,          632,          95, ...
  1.310076e+01, 1.514586e+01, 8.786040e+00, 1.297130e+01, ...
  ...
i_boutique.ref,i_boutique.e2
  0,            80,           400,          3, ...
  1.503223e+01, 1.191290e+01, 8.384595e+00, 6.479039e+00, ...
...
```

> **Remark:** by construction, the dissimilarity value should increase along each column.

We can define this file more formally as follows. Let `im_a` and `im_b` be the identifiers of two patch-images.  Let `nn(im_a.idx,im_b,n)` be the *index* of the *n*-th nearest neighbour of a patch `im_a.idx` to the patches in image `im_b`. Furthermore, let ``ds(im_a.idx,im_b,n)`` be the corresponding dissimilarity value. Then the file content is as follows:

```
im_a,im_b
nn(im_a.0,im_b,1), nn(im_a.1,im_b,1), ..., nn(im_a.M,im_b,1)
ds(im_a.0,im_b,1), ds(im_a.1,im_b,1), ..., ds(im_a.M,im_b,1)
nn(im_a.0,im_b,2), nn(im_a.1,im_b,2), ..., nn(im_a.M,im_b,2)
ds(im_a.0,im_b,2), ds(im_a.1,im_b,2), ..., ds(im_a.M,im_b,2)
...
nn(im_a.0,im_b,K), nn(im_a.K,im_b,K), ..., nn(im_a.M,im_b,N)
ds(im_a.0,im_b,K), ds(im_a.K,im_b,K), ..., ds(im_a.M,im_b,N)
im_c,im_d
nn(im_c.0,im_d,1), nn(im_c.1,im_d,1), ..., nn(im_c.P,im_d,1)
ds(im_c.0,im_d,1), ds(im_c.1,im_d,1), ..., ds(im_c.P,im_d,1)
...
```

For example, if a sequence `s_boring` contains only two patches,
and the nearest neighbors of `s_boring.a.0` are `s_boring.b.1` and `s_boring.b.0` with distance 12.3 and 14.2 respectively, and `s_boring.b.0, s_boring.b.1` are the nearest neighboors to `s_boring.a.1`, the results file should look something like:

```
s_boring.a,s_boring.b
1, 0
12.3, 7.5
0, 1
14.2, 27.4
```

### Generating and validating the result files

You can generate the results files with MATLAB scripts `matching_compute.m` and compute the PR curves and the AP with `matching_eval.m` in the *HBench* toolbox.

## References

[1] K. Mikolajczyk and C. Schmid. A performance evaluation of local descriptors. In IEEE TPAMI 2005.
