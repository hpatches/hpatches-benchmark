# Image and Patch Retrieval Benchmark

The *Patch Retrieval Benchmark* (PRB) evaluates the ability of a patch descriptors to retrieve corresponding patches in an image-to-many-image scenario. 

Similar to [1] and the [Image Matching Benchmark](../matching/README.md), this problem is formulated as a ranking task: for each reference patch, all target patches are sorted by descriptor similarity with the reference, and performance is measured by computing the average precision (AP) of the resulting rank list. A result is considered correct if it comes from the patch corresponding to the same physical surface (patch retrieval) or simply from the corresponding image (image retrieval). The latter is a relaxed criterion that ignore physically incorrect errors if they are semantically correct (e.g. retrieving a window for another in the same building).

The final performance is reported as the mean average precision (mAP) for all the reference patches. This is similar to the evaluation proposed in [1] and [2] for both image and patch retrieval.

[TOC]

## Benchmark definitions

From a defined pool of patches, an ideal image retrieval algorithm ranks the highest the patches coming from images of the same scene (called an "image sequence" in HPatches). For patch retrieval, the patches must be also come from the same physical surface (location) within the sequence of images. For simplicity, we use only the descriptor distance to rank the patches from the pool.

The benchmark is composed of a number of tasks, each defined by a corresponding `.benchmark` file. There are several such files:

```bash
> ls -1 benchmarks/retrieval/*.benchmark
benchmarks/retrieval/train_easy_40s_00.benchmark
benchmarks/retrieval/train_easy_40s_01.benchmark
benchmarks/retrieval/train_easy_5s_00.benchmark
benchmarks/retrieval/train_easy_5s_01.benchmark
benchmarks/retrieval/train_easy_5s_02.benchmark
benchmarks/retrieval/train_easy_5s_03.benchmark
benchmarks/retrieval/train_easy_5s_04.benchmark
benchmarks/retrieval/train_hard_40s_00.benchmark
benchmarks/retrieval/train_hard_40s_01.benchmark
benchmarks/retrieval/train_hard_5s_00.benchmark
benchmarks/retrieval/train_hard_5s_01.benchmark
benchmarks/retrieval/train_hard_5s_02.benchmark
benchmarks/retrieval/train_hard_5s_03.benchmark
benchmarks/retrieval/train_hard_5s_04.benchmark
```

Once the test set will be made available, corresponding `test_*` files will also be delivered.

The names of these files follow the pattern:

```
<train|test>_<easy|hard>_<num_sequences>s_<random_seed>.benchmark
```

where `<easy|hard>` is for easy or hard, indicating the amount of affine jitters between patches. The `<num_sequences>` is the number of patch-images (sequences) in the descriptor pool and `<random_seed>` is the random seed used to initialize the draws of the sequences. The number of draws is proportional to the number of sequences in the set (train/test).

### Benchmark file format

Each `*.benchmark` file has the structure:

```
List of patch-images
First query patch
Second query patch
...
```

For example, the file `train_easy_40s_00.benchmark` contains the following text:

``` bash
> cat benchmarks/retrieval/train_easy_40s_00.benchmark
i_smurf.ref,i_smurf.e1,i_smurf.e2,i_smurf.e3,i_smurf.e4,i_smurf.e5,v_artisans.ref,...
v_bricks.ref.85
i_dome.ref.1363
v_dirtywall.ref.643
...
```

The first line indicates that reference (query) patches must be compared to the patches contained in the patch-images `i_smurf.ref`, `i_smurf.e1`, ... The other lines indicates that the reference  patches are `v_bricks.ref.85`, `i_dome.ref.1363`, ...

> **Remark:** each reference patch is always contained in one of the specified patch-images.

## Entering the benchmarks

Entering the benchmark is conceptually simple:

1. For each benchmark task, identify the required patch-images.
2. Compute the descriptors for all patches in these patch-images.
3. Use your descriptor to compare each reference (query) patch to all patches. For this step, you can use your preferred distance measure (e.g. L1 or L2) or any other dissimilarity score.
4. Write the results of such comparisons to a ranked list.

In more detail, for each `*.benchmark` file, you need to write a corresponding `*.results` file. In order to allow comparing different descriptors, each file must be store in a descriptor-specific directory. So, if `my_desc` is the name of your descriptor, you need to write the four files:

```
results/retrieval/my_desc/train_easy_40s_00.results
results/retrieval/my_desc/train_easy_40s_01.results
results/retrieval/my_desc/train_easy_5s_00.results
results/retrieval/my_desc/train_easy_5s_01.results
...
```

### Result file format

The format of the `*.results` file is as follows:

```
List of patch-images
For the first reference (query) patch, list of top 51 patches by decreasing similarity score
For the second reference (query) patch, list of top 51 patches by decreasing similarity score
...
```

The first line is simply copied from the corresponding `*.benchmark` file. The other lines list, for each reference (query) patch, the top 51 matching patches by decreasing similarity. Since the query patch is always included in the pool of target patches, the first returned patch should always be the same as the query patch (as this one has distance zero or maximum similarity).

For example, the file `train_easy_40s_00.results` may look something like:

```bash
> cat results/retrieval/my_desc/train_easy_40s_00.results
i_smurf.ref,i_smurf.e1,i_smurf.e2,i_smurf.e3,i_smurf.e4,i_smurf.e5,v_artisans.ref,...
v_bricks.ref.85, v_grace.e5.1231,v_bricks.e1.85, v_bark.e1.666, ...
i_dome.ref.1363, v_sunseason.e5.1241, v_wapping.ref.156, v_astronautis.e4.133, ...
v_dirtywall.ref.643, v_dirtywall.e1.643, v_sunseason.ref.931, v_sunseason.ref.768, ...
...
```

### Generating and validating the result files

You can generate the results files with  `retrieval_compute.m` and compute the PR curves and the mAP with `retrieval_eval.m` in the *HBench* toolbox.

### Ground-truth labels file format

For each `*.benchmark` file, there is a corresponding `*.labels` file containing the ground-truth matching patches for each query patch. For example, the ground-truth file for the benchmark `train_easy_40s_00` looks like this:

```bash
> cat benchmarks/retrieval/train_easy_40s_00.labels
i_smurf.ref,i_smurf.e1,i_smurf.e2,i_smurf.e3,i_smurf.e4,i_smurf.e5,v_artisans.ref,...
v_bricks.ref.85,v_bricks.e1.85,v_bricks.e2.85,v_bricks.e3.85,v_bricks.e4.85,v_bricks.e5.85
i_dome.ref.1363,i_dome.e1.1363,i_dome.e2.1363,i_dome.e3.1363,i_dome.e4.1363,i_dome.e5.1363
v_dirtywall.ref.643,v_dirtywall.e1.643,v_dirtywall.e2.643,v_dirtywall.e3.643,v_dirtywall.e4.643,v_dirtywall.e5.643
v_boat.ref.1232,v_boat.e1.1232,v_boat.e2.1232,v_boat.e3.1232,v_boat.e4.1232,v_boat.e5.1232
```

This means that the query patch `v_bricks.ref.85` is in correspondence with the patches `v_bricks.ref.85`, `v_bricks.e1.85`, `v_bricks.e2.85`, `v_bricks.e3.85`, `v_bricks.e4.85`, and `v_bricks.e5.85` and so on. Using this information, it is possible to compute the AP and mAP for the patch retrieval task. For the image retrieval task, a match is considered correct provided that it comes from the correct image sequence (e.g. for the reference (query) patch `v_bricks.ref.85` this is any patch from the image sequence `v_bricks`).

## References

[1] M. Paulin et al. Convolutional Patch Representations for Image Retrieval: an Unsupervised Approach, http://arxiv.org/abs/1603.00438

[2] J. Philbin et al. Object retrieval with large vocabularies and fast spatial matching. CVPR 2007.
