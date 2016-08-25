# Patch Classification Benchmark

The *Patch Classification Benchmark* (PCB) evaluates the ability of a patch descriptor to discriminate pair of patches that are in correspondence (come from the same portion of a 3D surface) from non-corresponding ones.

This task is formulated as a classification problem, where the goal is to distinguish positive (matching) and negative (non-matching) pairs of patches. This is done by comparing the patch descriptors, for example by using the Euclidean distance between them. The resulting dissimilarity score is then (implicitly) thresholded to make a decision. Evaluation uses both the ROC (receiver operating characteristic) curves [1] and the PR (precision-recall) curves [2].

[TOC]

## Benchmark definitions

There are a number of variants of this evaluation, considering different sets of patch pairs. Each benchmark is defined by one of the following `*.benchmark` files:

```bash
> ls -1 benchmarks/classification/*.benchmark
train_diffseq_easy.benchmark
train_diffseq_hard.benchmark
train_sameseq_easy.benchmark
train_sameseq_hard.benchmark
```

> **Remark:** These files are relative to the training set; corresponding files will be released for the test set once the latter is made available.

Each benchmark file is a list of *sets of patch pair files* to include in the evaluation. For example, the file `train_diffseq_easy.benchmark` contains the following text:

```bash
> cat benchmarks/classification/train_diffseq_easy.benchmark
train_easy_pos.pairs
train_diffseq_neg.pairs
```

This means that the `train_diffseq_easy` benchmark is formed by the union of the two list of patch pairs `train_easy_pos` and `train_diffseq_neg`.

The `*.pairs` specify the list of patches to compare. These files are contained in the same directory as the `*.benchmark` files. Their content is a list of patch pairs. For example:

```bash
> cat benchmarks/classification/train_easy_pos.pairs
i_smurf.e4.854,i_smurf.e1.854
v_dirtywall.e4.1854,v_dirtywall.ref.1854
i_boutique.e5.721,i_boutique.e2.721
...
```

Here each line is in the form :

```
patch_a,patch_b
```

where `patch_a` and `patch_b` are patch identifiers. The format of the patch-images and of the patch-image and patch identifiers is discussed [here](../../README.md#reading-patches).


For each `*.benchmark` file, there is a corresponding `*.labels` file.
```bash
> cat benchmarks/classification/train_diffseq_easy.labels
1
1
...
0
0
...
```

which stores the corresponding pair labels (0 for a negative pair and 1 for a positive pair). So, for example for all pairs from `train_easy_pos.pairs`, the labels would be ones only. Please note that this does not hold for the test
files.

## Entering the benchmarks

Entering the benchmark is conceptually straightforward. One should:

1. Identify the list of patch pairs required for a given task.
2. For each patch pair in such lists, compute the patch descriptors and compare them using the preferred method (e.g. L1 or L2 distance).
3. Store the result of the comparison in a file.

In more detail, suppose you want to evaluate the `train_diffseq_easy.benchmark` task. Reading this file, reveals that this task requires comparing the patch pairs specified in the files `train_easy_pos.pairs` and `train_diffseq_neg.pairs`. For each of these files, in order, one should then visit all patch pairs and write the result of the comparison (the dissimilarity score) to a corresponding `train_diffseq_easy.benchmark`.

In order to allow evaluating different descriptors, the result files are written in descriptor-specific directories. For example, let `my_desc` be the name of your descriptor. To evaluate the `train_diffseq_easy.benchmark`,  you have to generate the file:

```
results/classification/my_desc/train_diffseq_easy.results
```

Each `*.results` file should contain a line for each tested pair specifying the resulting dissimilarity score:

```bash
> cat results/resize/classification/train_diffseq_easy.results
57.238895
27.800259
20.574526
32.282665
...
73.375366
74.484528
70.905136
35.064594
```
The `*.results` file must have as many records as the corresponding `*.labels` file.


### Evaluating all classification tasks

In order to evaluate *all* the classification tasks at once, simply write a `*.results` file for each `*.benchmark` file in `benchmarks/classification/*.benchmark`. There are only four such files (for each of training and test):

```bash
> ls -1 benchmarks/classification/*.benchmark
train_diffseq_easy.benchmark
train_diffseq_hard.benchmark
train_sameseq_easy.benchmark
train_sameseq_hard.benchmark
```

so you need to write (for each of train and test) four results files:

```
results/resize/classification/train_diffseq_easy.results
results/resize/classification/train_diffseq_hard.results
results/resize/classification/train_sameseq_easy.results
results/resize/classification/train_sameseq_hard.results
```

### Generating and validating the result files

You can generate the results files with MATLAB scripts `classification_compute.m` and compute the PR curves and the AP with `classification_eval.m` in the *HBench* toolbox.

## Benchmark contents

This appendix provide some context on the benchmark defined above.

### Tasks

As seen above, the benchmark defines four different classification tasks:

1. `train_diffseq_easy.benchmark`. The positive pairs are affected by only small affine distortion and patches in negative pairs are sampled from images from different scenes (different sequences).
2. `train_diffseq_hard.benchmark`. Same as above, but the positive pairs are affected by more affine distortion.
3. `train_sameseq_easy.benchmark`. Same as the first, but patches in negative pairs may also come from the same scene. This is in general a harder task, as matching repeating patterns (which often occur in the same scene) is considered incorrect.
4. `train_sameseq_hard.benchmark`. Same as above, but with more affine distortion in the positive patches.

In practice, each benchmark is obtained by combining list of patches, described below.

### Lists of patch pairs

The classification tasks are obtained by combining a number of patch pair lists. There are four such lists:

```bash
> ls -1 benchmarks/classification/*.pairs
train_easy_pos.pairs
train_hard_pos.pairs
train_diffseq_neg.pairs
train_sameseq_neg.pairs
```

The content of these lists is as follows:

* `train_easy_pos.pairs` contains positive pairs that are easier
to classify (smaller affine jitters).
* `train_easy_pos.pairs` contains positive pairs that are harder
to classify (larger affine jitters).
* `train_sameseq_neg.pairs` contains negative pairs that are
sampled from different sequences.
* `train_diffseq_neg.pairs` contains negative pairs that are sampled from the same sequence.

## References

[1] S. Winder, G. Hua and M. Brown - Picking the best daisy.

[2] E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua and  F. Moreno-Noguer
Discriminative learning of deep convolutional feature point descriptors.

[3] J. Davis and M. Goadrich. The relationship between PR and ROC curves. In ICML, 2006.
