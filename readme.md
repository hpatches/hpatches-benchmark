![logo](https://hpatches.github.io/assets/hpatches-logo.png "logo") 
## Homography patches dataset 

This repository contains the code for evaluating feature descriptors
on the `HPatches` dataset. For more information on the methods and the
evaluation protocols please check [[1]](#refs).

### Benchmark implementations

We provide two implementations for computing results on the HPatches
dataset, one in `python` and one in `matlab`.

| `python`        |   `matlab`  |
| ------------- |:-------------:|
|  [details](python/readme.md) | [details](matlab/README.md) |

### Benchmark tasks

Details about the benchmarking tasks can he found
[here](docs/tasks.md).  
For a more in-depth description, please see the CVPR
2017 paper [[1]](#refs).

### Getting the dataset

The data required for the benchmarks are saved in the `./data` folder,
and are shared between the two implementations.

To download the `HPatches` image dataset, run the provided shell script
with the `hpatches` argument.

``` bash
sh download.sh hpatches
```
To download the pre-computed files of a baseline descriptor `X` on the
`HPatches` dataset, run the provided `download.sh` script with the
`descr X` argument.  

To see a list of all the currently available descriptor file results,
run scipt with only the `descr` argument.

``` bash sh 
sh download.sh descr       # prints all the currently available baseline pre-computed descriptors
sh download.sh descr sift  # downloads the pre-computed descriptors for sift
```

The `HPatches` dataset is saved on `./data/hpatches-release` and the pre-computed descriptor files are saved on `./data/descriptors`.


### Dataset description

After download, the folder `../data/hpatches-release` contains all the
patches from the 116 sequences. The sequence folders are named with
the following convention

* `i_X`: patches extracted from image sequences with illumination changes
* `v_X`: patches extracted from image sequences with viewpoint changes

For each image sequence, we provide a set of reference patches
`ref.png`. For the remaining 5 images in the sequence, we provide
three patch sets `eK.png` and `hK.png` and `tK.png`, containing the
corresponding patches from `ref.png` as found in the `K-th` image with
increasing amounts of geometric noise (`e`<`h`<`t`).

![patches](./python/utils/imgs/patches.png "patches") 

Please see the [patch extraction method details](./python/utils/docs/extraction.md) for more
information about the extraction process. 



### References
<a name="refs"></a>

[1] *HPatches: A benchmark and evaluation of handcrafted and learned local descriptors*, Vassileios Balntas*, Karel Lenc*, Andrea Vedaldi and Krystian Mikolajczyk, CVPR 2017.
*Authors contributed equally.



> *You might also be interested in the [3D reconstruction](https://github.com/ahojnnes/local-feature-evaluation) benchmark by Schönberger et al. also presented at CVPR 2017.*


