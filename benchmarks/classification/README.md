# Patch classification benchmark

The *Patch Classification Benchmark* (PCB) measures the ability of a patch descriptor to discriminate pair of patches that are in correspondence (come from the same 3D surface) from non-corresponding ones. 

This task is formulated as a classification problem, where the goal is to distinguish positive (matching) and negative (non-matching) pairs of patches. This is done by comparing the patch descriptors, for example by using the Euclidean distance between them. The resulting dissimilarity score is then (implicitly) thresholded to make a decision. Evaluation uses both the ROC (receiver operating characteristic) curves [1] and the P-R (precision-recall) curves [2].

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

> **Remark:** These files are from the training set. Soon, we will release four more `test_*` files for the test set.

Each benchmark file is a list of *sets of patch pairs* to include in the evaluation. For example, the file `train_diffseq_easy.benchmark` contains the following text:

```bash
> cat benchmarks/classification/train_diffseq_easy.benchmark
train_easy_pos.pairs
train_diffseq_neg.pairs
```

This means that the `train_diffseq_easy` benchmark is formed by the union of the two list of patch pairs `train_easy_pos` and `train_diffseq_neg`. The `*.pairs` files are contained in the same directory as the `*.benchmark` files. Their content is a list of labelled patch pairs. For example:

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

where `patch_a` and `patch_b` are patch identifiers and `label` is the corresponding pair label (0 for a negative pair and 1 for a positive pair). In the example above, all the labels are 1 because the list contains only positive pairs.

> **TODO**: add a pointer to the patch id format.

## Entering the benchmarks

Entering the benchmark is conceptually straightforward:

1. Identify the list of patch pairs required.
2. For each patch pair in such lists, compute the patch descriptors and compare them using your preferred method (e.g. L1 or L2 distance).
3. Store the result of the comparison in a file.

In more detail, suppose you want to enter the `train_diffseq_easy.benchmark` benchmark. This requires generating results for the lists of patch pairs `train_easy_pos.pairs` and `train_diffseq_neg.pairs`. For each of these files, visit all patch pairs and write the result of the comparison (dissimilarity score) to a corresponding `train_easy_pos.results` and `train_diffseq_neg.results` files.

In order to allow evaluating different descriptors, files are written in descriptor-specific directories. Thus let `my_desc` be the name of your descriptor. To enter this benchmark, you have to write the following files:

```
results/classification/my_desc/train_easy_pos.results
results/classification/my_desc/train_diffseq_neg.results
```

Each file should contain a line for each tested pair with the dissimilarity score and the ground truth label, separated by a comma:

```bash
> cat results/classification/my_desc/train_easy_pos.results
1.2,1
0.1,1
3.8,1
...
0.5,1
```

> **TODO:** Injecting the ground truth information in the result file is a bad idea and there is no need to do it.

You can use the HBench tool in order to validate these files and compute the ROC and PR curves.

> **TOOD:** give an example

### Entering all classification benchmarks

In order to enter *all* the classification benchmarks, simply write a `*.results` files for all possible `*.pairs` files. There are only four such files (for each of training and test):

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

## Appendix: benchmark contnets

This appendix provide some context on the benchmark defined above.

### Benchmarks

As seen above, we define four different classification benchmarks:

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

There are four lists of patch pairs:

```bash
> ls -1 benchmarks/classification/*.pairs
train_easy_pos.pairs
train_hard_pos.pairs
train_diffseq_neg.pairs
train_sameseq_neg.pairs
```

These lists are defined as follows:

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
