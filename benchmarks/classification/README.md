# Classification benchmark

This benchmark evaluates the performance of feature descriptors when
used as simple naive bayes classifiers, based on thresholding of
distance between positive and negative pairs.

Evaluation can be done either in terms of ROC [1] curves, or P-R
curves [2].

We provide two protocols for the evaluation:

1) *Balanced positive and negative pairs*
This is based on a balanced positive and negative pairs dataset similarly to [1].

2) *Imbalanced positive and negative pairs*
This is based on the idea that the
number of positive pairs are sifnicicantly less compared to negative
pairs, so we also provide a separate list of 1M negatives that can be
used together with the 200K positive ones to test the
performance. Note that in this case, ROC curves should not be used 
they are not food for imbalanced datasets [3].


# Pair files description

We provide 4 files with ground truth pairs for patch pair
classification.

E.g. the files for the test set are
``` bash
test_neg_diffseq.pairs
test_neg_sameseq.pairs
test_pos_easy.pairs
test_pos_hard.pairs
```

`classification_pos_easy.txt` contains positive pairs that are easier
to classify (smaller affine jitters)

`classification_pos_hard.txt` contains positive pairs that are harder
to classify (larger affine jitters)


`classification_neg_diffseq.txt` contains negative pairs that are
sampled from different sequences 

`classification_neg_sameseq.txt` contains negative pairs that are
sampled from the same sequence. This allows for harder cases such as
repeating patterns.

# Evaluation

For each patch pair, use your descriptor to compute the
feature vector for both patches of the pair. Then use your required
distance measure (e.g. L1 or L2), to get a pair distance.  

E.g. if your descriptor is called X, your results will be called

``` bash
X_test_neg_diffseq.results
X_test_neg_sameseq.results
X_test_pos_easy.results
X_test_pos_hard.results
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

Use the provided codes in python, matlab or torch to compute the ROC
curves, and the PR curves, and save the results using your descriptor
name (scripts will be provided soon).

# References
[1] S. Winder, G. Hua and M. Brown - Picking the best daisy

[2] E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua and  F. Moreno-Noguer
Discriminative learning of deep convolutional feature point descriptors

[3] J. Davis and M. Goadrich. The relationship between PR and ROC curves. In ICML , 2006
