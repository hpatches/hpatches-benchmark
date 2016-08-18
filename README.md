# HBench

*HBench* is a toolbox for evaluating local feature descriptors using the [*HPatches*](https://github.com/featw/hpatches) (Homography Patches) dataset and benchmark.
This toolbox supports the descriptor matching challenge that will be presented at the
[Local Features: State of the Art, Open Problems and Performance Evaluation](http://www.iis.ee.ic.ac.uk/ComputerVision/DescrWorkshop/index.html)
workshop at ECCV 2016. It implements the *HPatches* evaluation protocol and allows to produce the result files required to enter the challenge.

[TOC]

## Quick start

The *HPatches* benchmark assess local patch descriptors using a number of complementary tests. There are two ways to run such tests and enter the challenge:

1. **Provide the patch descriptors and use HBench to compute the result files.** This is the simplest although slightly less flexible manner. In this case, one simply computes a patch descriptor for each patch in *HPatches*, stores it in a CSV file, and uses the *HBench* toolbox to generate the result files. The main limitation is that descriptors are implicitly compared using the Euclidean distance.

2. **Provide the result files directly.** This method is more flexible as it allows to compare descriptors using an arbitrary method, but it requires to generate the result files directly. In particular, for each  `*.benchmark` file found in the folder hierarchy `benchmarks/`, one must provide a corresponding `*.results` file.

The rest of this page discusses the first method, which relies on the *HBench* software. *HBench* provides a simple command line interface
for producing the `.results` files from descriptors stored in CSV files. *HBench* is written in MATLAB, but you do not need to own a MATLAB license as we provide a [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) which needs only on the freely available MATLAB Compiler Runtime (MCR).

### Participate in the challenge

To obtain the results files, once the test set is released, you generally proceed as follows:

* **Install HBench.** Download and unpack the [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) of *HBench*. Let `HBPATH` be the path to the install directory.
* **Install HPatches.** Download the [HPatches](https://github.com/featw/hpatches) dataset. You can download the dataset directly or by running the script `HBPATH/bin/run_hb.sh MCRPATH` available in the *binary* distribution of HBench (see above). Make sure that the HPatches data is unpacked in the subfolder `HBPATH/data/` of the HBench install.
* **Install the required MATLAB components.** Install either MATLAB R2016a or the free MATLAB redistributable environment [MCR R2016a](http://www.mathworks.com/products/compiler/mcr/). In the following, let `MCRPATH` be the path to either the MATLAB or MCR install. See [Install MCR](#install-mcr) for more details.
* **Compute the patch descriptors.** The HPatches dataset is organized in patch-images in `HBPATH/data/hpatches/SEQUENCE/IMNAME.png`. For each patch-image compute the descriptor `DESCNAME` (where `DESCNAME` is an arbitrary descriptor name such as `SIFT`) and store it in a numeric [CSV file](#csv-descriptors)
`HBPATH/data/descriptors/DESCNAME/SEQUENCE/IMNAME.csv` with one descriptor per line.
* **Compute the result files.** This can be done in one go from the command line using `HBPATH/bin/run_hb.sh MCRPATH pack DESCNAME`.
This command checks the validity of descriptors, computes the results and asks for some
details about your submission. More details about the interface can be found [here](#command-line-interface).
* **Submit the results.** Send the archive `./DESCNAME_results.zip` to the [Dropbox submission folder](https://www.dropbox.com/request/2MJm7vV15XJnl1RzuCzl).

Additionally, you can also experiment with the MATLAB code directly, using the
provided interface to compute your own descriptors. You can also clone the
[GIT repository](https://github.com/featw/hbench), but in order to run the source code you will need a MATLAB license.

### Install MCR
The command line interface requires either MATLAB R2016a or the MATLAB Compiler Rumtime (MCR) installed. If you do not have MATLAB, you can download and install the MCR for free as follows:

* [Download MCR for Linux 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip)
Download the zip archive, unpack and run the `./install` script.
* [Download MCR for Windows 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/win64/MCR_R2016a_win64_installer.exe)
Download and run the `.exe` installer.
* [Download MCR for Mac 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/maci64/MCR_R2016a_maci64_installer.zip)
Download the zip archive, unpack and run the `./install` script.

More details how to install the MCR can be found [here](http://www.mathworks.com/products/compiler/mcr/).
Please note that around 2GB of free space is required.

<a id=command-line-interface></a>

### Command line interface
To run the *HBench* command line interface with the MCR located in the default path, run:
``` bash
./bin/run_hb.sh /usr/local/MATLAB/MATLAB_Runtime/v901 COMMAND DESCNAME BENCHMARK
```
If you have MATLAB installed in `/usr/local/MATLAB/R2016a`, you can use that
instead of the MCR:
``` bash
./bin/run_hb.sh /usr/local/MATLAB/R2016a COMMAND DESCNAME BENCHMARK
```
You can see the list of all available commands [here](./bin/README.md).

### MATLAB Interface

If you have MATLAB R2016a installed, you can also easily run the `hb` function directly in MATLAB by running e.g.:

``` bash
cd matlab
hb COMMAND DESCNAME BENCHMARK
```

Or you can experiment directly with the evaluation functions and the dataset
structures. There are few examples prepared in `matlab/example_*.m`.

### CSV Descriptors
Descriptors should be stored in simple comma-separated files. They can contain only numeric
values. The data are organized as one descriptor per line. All descriptors must have the same number of elements.

For example, for a patch image  `data/hpatches/i_ski/ref.png` and a MEGADEEP descriptor there will be a CSV file `data/descriptors/megadeep/i_ski/ref.csv` with 623 lines (one line per descriptor). The CSV can contain only numeric values.

You can check if you have descriptors for all image files in a valid format with:
```
bin/run_hb.sh MCRPATH checkdesc DESCNAME
```

### Compute Baseline Descriptors
To compute the baseline descriptors and to check if everything works as it should,
you can run:
```
./bin/run_hb.sh MCRPATH computedesc DESCNAME
```
Currently implemented descriptors are `sift`, `meanstd` and `resize`.

## The challenge's tasks

The challenge consists of three common computer vision tasks:

* [Patch Classification](./benchmarks/classification/README.md)
* [Image Matching](./benchmarks/matching/README.md)
* [Image and Patch Retrieval](./benchmarks/retrieval/README.md)

## Referencing patch-images and patches
For referring patch-images we use the following signatures:
```
SEQUENCE.IMNAME
```
where the image is stored in `data/hpatches/SEQUENCE/IMNAME.png`.

For referring a particular patch within the image we use a signature:
```
SEQUENCE.IMNAME.PATCH_IDX
```
Where `PATCH_IDX` is a zero-based index within the patches. How to get a particular patch is shown in the following pseudo-code:
``` python
image = read_image('data/hpatches/SEQUENCE/IMNAME.png');
patch = image(start_row=patch_num*65, end_row=(patch_num+1)*65);
```
Patches with the same index has been extracted from the same location in the scene (plus some additional noise) within the sequence.
