# Patch classification benchmark

The *Patch Classification Benchmark* (PCB) evaluates the performance of patch descriptors used to compare patch pairs and classify them as positive or negative based on the resulting patch similarity score. By default, descriptors are compared using the Euclidean distance. Evaluation can be done either in terms of ROC (receiver operating characteristic) curves [1] or P-R (precision-recall) curves [2].

We provide two protocols for the evaluation:

1. **Balanced positive and negative pairs.**
This is based on a balanced dataset with an equal number of positive and negative pairs. This setup is similar to [1].

2. **Imbalanced positive and negative pairs.**
This is based on the idea that the
number of positive pairs is significantly smaller compared to negative
pairs, so we also provide a separate list of 1M negative paris that can be
used together with the 200K positive ones to test the
performance. Note that in this case ROC curves should not be used for evaluation as they are not appropriate for highly-imbalanced datasets [3].

## Pairs files

We provide 4 files with ground truth pairs for patch pair classification.

E.g. the files for the test set are
``` bash
test_pos_easy.pairs
test_pos_hard.pairs
test_neg_diffseq.pairs
test_neg_sameseq.pairs
```

`test_pos_easy.pairs` contains positive pairs that are easier
to classify (smaller affine jitters).

`test_pos_hard.pairs` contains positive pairs that are harder
to classify (larger affine jitters).


`test_neg_diffseq.pairs` contains negative pairs that are
sampled from different sequences.

`test_neg_sameseq.pairs` contains negative pairs that are
sampled from the same sequence. This allows for harder cases such as
repeating patterns.

The contents of the files is as follows:
``` bash
patch_a,patch_b,label # First pair
patch_x,patch_y,label # Second pair
...
```
Where the patch signatures `patch_a` and `patch_b` are followed by a label
(0 for negative pair, 1, for positive pair).

## Evaluation

For each patch pair, use your descriptor to compute the
feature vector for both patches of the pair. Then use your required
distance measure (e.g. L1 or L2), to get a pair distance.

E.g. for a descriptor `desc_name` and pairs file `pairs_file`,
your results should be stored in:
``` bash
../results/classification/desc_name/pairs_file.results
```
So, if you call your descriptor `benchmark_killer`, your results will be
stored in 4 files:
```
../results/classification/benchmark_killer/test_pos_easy.results
../results/classification/benchmark_killer/test_pos_hard.results
../results/classification/benchmark_killer/test_neg_diffseq.results
../results/classification/benchmark_killer/test_neg_sameseq.results
```

Each file will contain a distance, and a label:
e.g.
```
1.2,0
0.1,1
3.8,0
...
0.5,1
```

Use the provided codes in MATLAB to compute the ROC
curves, and the PR curves, and save the results using your descriptor
name.

## References
[1] S. Winder, G. Hua and M. Brown - Picking the best daisy

[2] E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua and  F. Moreno-Noguer
Discriminative learning of deep convolutional feature point descriptors

[3] J. Davis and M. Goadrich. The relationship between PR and ROC curves. In ICML , 2006
