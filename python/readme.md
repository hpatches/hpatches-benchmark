![logo](./utils/imgs/hpatch.png "logo") 
## Python implementation of the HPatches benchmark protocols

This repository contains the `python` code for evaluating feature
descriptors on the `HPatches` dataset. For more information on the
methods and the evaluation protocols please check [[1]](#refs).

### Prerequisites

To install the required packages on Ubuntu, run the following commands:

``` sh 
pip install -r utils/requirements.txt --user
sudo apt-get install libopencv-dev python-opencv
```

For other `Linux` distributions or `macOS` please see the
[guide](utils/docs/prerequisites.md).

### Downloading the HPatches dataset
The rest of this document assumes you have already downloaded the
HPatches dataset. For information on how to get it, please check
[the guide](../readme.md).  

### Loading/visualising the dataset
An example of how to load a sequence and visualise the patches can be
found in the `hpatches_vis.py` file included in the repository:

``` sh
python hpatches_vis.py
```

### Evaluating descriptors

We provide code for evaluating descriptors in the three different
tasks described on [[1]](#refs). Details about the task definition
files, can be found [here](utils/docs/tasks.md).

Note that that task definition files are saved in
[../tasks/](../tasks/) and are shared between the `python` and
`matlab` implementations of the `HPatches` benchmark.


##### Running evaluation tasks
The script expects two required arguments which are the root folder of
the saved `.csv` files (`--descr-dir`), and the task to perform
`[verification, matching, retrieval]`, for example:


```sh
python hpatches_eval.py --descr-name=sift --task=verification --delimiter=";"
```
gets the `verification` results for the `sift` descriptor. 

You can perform several tasks at once by repeating the `--task` argument:

```sh
python hpatch_eval.py --descr-dir=descrs/sift/ --task=verification --task=matching --delimiter=";"
```

There are also several optional arguments (e.g. delimiter for the
`.csv` files, split to perform the evaluation). For a full list and
a more detailed explanation, run the following:

```sh
python hpatch_eval.py --h
```

##### Results caching 
Results are cached in the `results` folder, for each task and for each
descriptor. If you want to re-compute the results for your descriptor,
simply manually delete the respective files in the `results`
sub-folder.

##### Training/test splits

We provide [several pre-computed splits](./utils/splits.json) to
encourage reproducibility.  Current available splits are
[`a (ECCV)`,`b`,`c`,`illum`,`view`,`full`]. More
information can be found [here](./utils/docs/splits.md).
  
##### Some usage examples of the evaluation script
```sh
python hpatch_eval.py --descr-dir=descrs/sift/ --task=matching --delimiter=";"
python hpatch_eval.py --descr-dir=descrs/misigma/ --task=retrieval  --split=b
python hpatch_eval.py --descr-dir=descrs/deepdesc/ --task=verification --task=matching --task=retrieval
```

##### Evaluating your descriptor

To evaluate your descriptor, assuming that the root folder containing
the `.csv` files for your descriptor is
`descrs/DESC/` simply input to the `--descr` argument your path:

```sh
python hpatch_eval.py --descr-dir=descrs/DESC/ --task=retrieval 
```

### Printing evaluation results 

An example script that shows how to read and print the evaluation
results from already cached result files can be found in `hpatch_results.py`.
Required parameters are `--descr` descriptor name (e.g. `sift`),
`--results-dir` results root folder (e.g. `results/`), `--task` task
name (e.g. {verification,matching,retrieval}). For example:

```sh
python hpatch_results.py --descr=sift --results-dir=results/ --task=verification
```

Note that as the previous scripts, it can accept multiple descriptors and multiple tasks e.g.

```sh
python hpatch_results.py --results-dir=results/ --descr=sift --descr=deepdesc  --task=verification --task=retrieval
```

### References
<a name="refs"></a>

[1] *HPatches: A benchmark and evaluation of handcrafted and learned local descriptors*, Vassileios Balntas*, Karel Lenc*, Andrea Vedaldi and Krystian Mikolajczyk, CVPR 2017.
*Authors contributed equally.
