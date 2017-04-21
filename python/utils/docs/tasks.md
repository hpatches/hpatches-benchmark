![logo](../imgs/hpatch.png "logo") 
## Homography patches dataset 

### Task definitions

We provide provide 3 separate tasks, inspired by different practical
aspects of local feature descriptors. In depth details can be found on
[1].


| task name     | description |
| ------------- |:-------------:|
| `verification`| measures how well a descriptor separates positive from negative pairs of patches  | 
| `matching`  | measures how well a descriptor matches two images | 
| `retrieval` | measures how well a descriptor retrieves similar patches from a large collection | 

Description of the task definition files


#### Verification definition files

For the `verification` task, for each split `X`, we provide 3 files:

| file name     | description |
| ------------- |:-------------:|
| `verif_pos_split-X.csv`| contains the positive pairs | 
| `verif_neg_inter_split-X.csv`  | contains negative pairs sampled from between sequences | 
| `verif_neg_intra_split-X.csv` | contains negative pairs sampled from withing sequences| 


In `utils/tasks/` we provide the task definition files for both positive and negative pairs, which are of the form 

Negative pairs:
```
s1,t1,idx1,s2,t2,idx2
v_birdwoman,4,251,i_resort,3,204
v_strand,1,1625,i_santuario,3,482
i_salon,0,1100,i_ajuntament,3,544
...
```

Positive pairs:
```
s1,t1,idx1,s2,t2,idx2
v_birdwoman,4,251,v_birdwoman,3,251
v_strand,1,1625,v_strand,3,1625
i_salon,0,1100,i_salon,3,1100
i_zion,3,1766,i_zion,0,1766
...
```

Each pair is defined by the items of the header
`s1,t1,idx1,s2,t2,idx2` where `s` represents the sequence, `t` the
image id from which the patch is extracted (0-5 since in HPatch there are 6 images per sequence), and `idx` the index of the patch inside the
sequence. 

For example the, patch `v_birdwoman,4,251` is 252th patch from the
`v_birdwoman` sequence, extracted from the `5th` image and the
`v_birdwoman,0,251` is the same, patch, but extracted from the
`ref` image.

Note that you can visualise individual patches using the `hpatch_vis.py` script provided. 



#### Retrieval definition files


For the retrieval task, we provide two files per split `X`:

| file name     | description |
| ------------- |:-------------:|
| `retr_queries_split-X.csv`| contains the queries | 
| `retr_distractors_split-X-X.csv`  | contains the pool with the distractors | 


Note that the file contents are slightly different than the ones in
the `verification` task:

```
s,idx
v_man,841
v_birdwoman,1758
v_coffeehouse,219
i_salon,986
v_yuri,9
i_ajuntament,799
```

since in the retrieval task, only the patches from the `ref` image are
used, and thus, there is no need for the `t` index.

#### Matching task

The matching task, does not make use of definition files, since due to
its nature there is no need for repeatability enforcement.
