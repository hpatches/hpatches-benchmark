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

Each benchmark file is a list of *sets of patch pairs* to include in the evaluation. For example, the file `train_diffseq_easy.benchmark` contains the following text:

```bash
> cat benchmarks/classification/train_diffseq_easy.benchmark
train_easy_pos.pairs
train_diffseq_neg.pairs
```

This means that the `train_diffseq_easy` benchmark is formed by the union of the two list of patch pairs `train_easy_pos` and `train_diffseq_neg`. 

The `*.pairs` specify the list of patches to compare. These files are contained in the same directory as the `*.benchmark` files. Their content is a list of labelled patch pairs. For example:

```bash
> cat benchmarks/classification/train_easy_pos.pairs
i_smurf.e4.854,i_smurf.e1.854,1
v_dirtywall.e4.1854,v_dirtywall.ref.1854,1
i_boutique.e5.721,i_boutique.e2.721,1
...
```

Here each line is in the form :

```
patch_a,patch_b,label
```

where `patch_a` and `patch_b` are patch identifiers and `label` is the corresponding pair label (0 for a negative pair and 1 for a positive pair). In the example above, all the labels are 1 because the list contains only positive pairs. The format of the patch-images and of the patch-image and patch identifiers is discussed [here](../../README.md#reading-patches).

## Entering the benchmarks

Entering the benchmark is conceptually straightforward. One should:

1. Identify the list of patch pairs required for a given task.
2. For each patch pair in such lists, compute the patch descriptors and compare them using the preferred method (e.g. L1 or L2 distance).
3. Store the result of the comparison in a file.

In more detail, suppose you want to evaluate the `train_diffseq_easy.benchmark` task. Reading this file, reveals that this task requires comparing the patch pairs specified in the files `train_easy_pos.pairs` and `train_diffseq_neg.pairs`. For each of these files, one should then visit all patch pairs and write the result of the comparison (the dissimilarity score) to corresponding `train_easy_pos.results` and `train_diffseq_neg.results` files.

In order to allow evaluating different descriptors, the result files are written in descriptor-specific directories. For example, let `my_desc` be the name of your descriptor. To evaluate the `train_diffseq_easy.benchmark`,  you have to generate the files:

```
results/classification/my_desc/train_easy_pos.results
results/classification/my_desc/train_diffseq_neg.results
```

Each file should contain a line for each tested pair specifying the resulting dissimilarity score and the ground truth label, separated by a comma:

```bash
> cat results/classification/my_desc/train_easy_pos.results
1.2,1
0.1,1
3.8,1
...
0.5,1
```

> **TODO:** Injecting the ground truth information in the result file is a bad idea and there is no need to do it.

### Evaluating all classification tasks

In order to evaluate *all* the classification tasks at once, simply write a `*.results` file for each `*.pairs` file in `benchmarks/classification/*.pairs`. There are only four such files (for each of training and test):

```bash
> ls -1 benchmarks/classification/*.pairs
train_easy_pos.pairs
train_hard_pos.pairs
train_diffseq_neg.pairs
train_sameseq_neg.pairs
```

so you need to write (for each of train and test) four results files:

```
results/classification/my_desc/train_easy_pos.results
results/classification/my_desc/train_hard_pos.results
results/classification/my_desc/train_diffseq_neg.results
results/classification/my_desc/train_sameseq_neg.results
```

### Generating and validating the result files

You can generate the results files with MATLAB scripts `classification_compute.m` and compute the PR curves and the AP with `classification_eval.m` in the *HBench* toolbox.

## Benchmark contents

This appendix provide some context on the benchmark defined above.

### Tasks

As seen above, the benchmark defines four different classification tasks:

1. `train_diffseq_easy.benchmark`
2. `train_diffseq_hard.benchmark`
3. `train_sameseq_easy.benchmark`
4. `train_sameseq_hard.benchmark`

> **TODO:** The description below does not match in an obvious way the four files above. Please fix.

1. **Balanced positive and negative pairs.**
This is based on a balanced dataset with an equal number of positive and negative pairs. This setup is similar to [1].

2. **Imbalanced positive and negative pairs.**
This is based on the idea that the
number of positive pairs is significantly smaller compared to negative
pairs, so we also provide a separate list of 1M negative paris that can be
used together with the 200K positive ones to test the
performance. Note that in this case ROC curves should not be used for evaluation as they are not appropriate for highly-imbalanced datasets [3].

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
* `train_diffseq_neg.pairs` contains negative pairs that are sampled from the same sequence. This allows for harder cases such as repeating patterns.


## References

[1] S. Winder, G. Hua and M. Brown - Picking the best daisy

[2] E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua and  F. Moreno-Noguer
Discriminative learning of deep convolutional feature point descriptors

[3] J. Davis and M. Goadrich. The relationship between PR and ROC curves. In ICML , 2006
