# Image and Patch Retrieval Benchmark
This benchmark evaluates performance of a feature descriptor in ranking task for image-to-many-images matching. Similarly as in [1] using the mean Average Precision (mAP) measure, proposed in [2], for both image and patch retrieval.

From a defined pool of patches, an ideal image retrieval algorithm ranks the highest the patches from the same sequence. For patch retrieval, the patches must be also from the same location within the sequence of images. For simplicity, we use only the descriptor distance to rank the patches from the pool.

The retrieval tasks are defined in multiple files names as follows:
```
<train|test>_<easy|hard>_<num_sequences>s_<random_seed>.benchmark
```
where `<easy|hard>` is for easy or hard affine jitters between patches. The `<num_sequences>` is the number of sequences in descriptor pool and `<random_seed>` is the random seed used to initialize the draws of the sequences. The number of draws is proportional to the number of sequences in the set (train/test).

The format of the `.benchmark` files is as follows:
``` bash
poolim_1,poolim_2,... # List of descriptors pool
querypatch_1 # Signature of the first query patch
querypatch_2
...
```
Where the first line is a list of image signatures which patches are in the descriptors pool. It is followed by the set of queries. Each query is a single patch signature and is within the pool of descriptors.

# Evaluation
For each patch-image pair, use your descriptor to compute the feature vector for all patches of the images. Then use your required distance measure (e.g. L1 or L2) to find the closest descriptors for each query from the descriptor pool.

You can generate the results files with MATLAB scripts `../retrieval_compute.m` and compute the PR curves and the mAP with `../retrieval_eval.m`.

For a descriptor `desc_name` and a benchmark `bench_name`, your results should be stored in:
``` bash
../results/retrieval/desc_name/bench_name.results
```


The format of the `*.results` file is as follows:
```
poolim_1,poolim_2,...
querypatch_1,2nd_closest_patch,...,51st_closest_patch
querypatch_2,...
...
```
the first line with the set of descriptor pool images is provided for a reference. It is followed by a list of signatures of the 51 closest patches for each query patch. As the query patch is always contained in the descriptor pool, the first patch has to be the query patch.

# References
[1] M. Paulin et al. Convolutional Patch Representations for Image Retrieval: an Unsupervised Approach, http://arxiv.org/abs/1603.00438

[2] J. Philbin et al. Object retrieval with large vocabularies and fast spatial matching. CVPR 2007.
