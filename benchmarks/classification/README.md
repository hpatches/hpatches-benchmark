# Patch classification benchmark

The *Patch Classification Benchmark* (PCB) measures the ability of a patch descriptor to discriminate pair of patches that are in correspondence (come from the same 3D surface) from non-corresponding ones. 

This task is formulated as a classification problem, where the goal is to distinguish positive (matching) and negative (non-matching) pairs of patches. This is done by comparing the patch descriptors, for example by using the Euclidean distance between them. The resulting dissimilarity score is then (implicitly) thresholded to make a decision. Evaluation uses both the ROC (receiver operating characteristic) curves [1] and the P-R (precision-recall) curves [2].

There are two variants of this evaluation, considering different sets of patch pairs.

1. **Balanced positive and negative pairs.**
This is based on a balanced dataset with an equal number of positive and negative pairs. This setup is similar to [1].

2. **Imbalanced positive and negative pairs.**
This is based on the idea that the
number of positive pairs is significantly smaller compared to negative
pairs, so we also provide a separate list of 1M negative paris that can be
used together with the 200K positive ones to test the
performance. Note that in this case ROC curves should not be used for evaluation as they are not appropriate for highly-imbalanced datasets [3].

Evaluating your descriptor using this benchmark is conceptually simple: get a list of patch pairs to compare, use your patch descriptor and preferred distance measure (e.g. L1 or L2) to perform the comparisons, and store the result of the comparisons in a file. The rest of this page describes how to do this.

## Pairs files

First, you need to identify a list of patches to compare. For each of train and test, there are four lists of patches with corresponding ground truth labels, stored in as many files. For example, for the `test` set there are the following four files:

```
test_pos_easy.pairs
test_pos_hard.pairs
test_neg_diffseq.pairs
test_neg_sameseq.pairs
```

* `test_pos_easy.pairs` contains positive pairs that are easier
to classify (smaller affine jitters).
* `test_pos_hard.pairs` contains positive pairs that are harder
to classify (larger affine jitters).
* `test_neg_diffseq.pairs` contains negative pairs that are
sampled from different sequences.
* `test_neg_sameseq.pairs` contains negative pairs that are sampled from the same sequence. This allows for harder cases such as repeating patterns.

The contents of the files is as follows:

```
patch_a,patch_b,label
patch_x,patch_y,label
...
```

Where `patch_a` and `patch_b` are patch identifiers and `label` is the corresponding pair label (0 for a negative pair and 1 for a positive pair).

## Generating the result files for evaluation

For each patch pair, use your descriptor to compute the
feature vector for both patches in the pair. Then use your preferred
distance measure (e.g. L1 or L2) to get a pair distance or other real dissimilarity score.

Let `desc_name` the name of your descriptor. For each file `pairs_file.pairs` containing a list of patches, write the corresponding scores separated by commas in a text `pairs_file.results`. These files should be stored in a suitable folder hierarchy as follows:

```
../results/classification/desc_name/pairs_file.results
```

For example, if your descriptor is called `benchmark_killer`, your results should be written to the following 4 files:

```
../results/classification/benchmark_killer/test_pos_easy.results
../results/classification/benchmark_killer/test_pos_hard.results
../results/classification/benchmark_killer/test_neg_diffseq.results
../results/classification/benchmark_killer/test_neg_sameseq.results
```

Each file should contain a line for each tested pair with the dissimilarity score and the ground truth label, separated by a comma:

```
1.2,0
0.1,1
3.8,0
...
0.5,1
```

Use the provided codes in MATLAB to compute the ROC and PR curves.

## References

[1] S. Winder, G. Hua and M. Brown - Picking the best daisy

[2] E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua and  F. Moreno-Noguer
Discriminative learning of deep convolutional feature point descriptors

[3] J. Davis and M. Goadrich. The relationship between PR and ROC curves. In ICML , 2006
