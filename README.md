# HBench

*HBench* is a toolbox for evaluating local feature descriptors using the [*HPatches*](https://github.com/featw/hpatches) (Homography Patches) dataset and benchmark.
This toolbox supports the descriptor matching challenge that will be presented at the
[Local Features: State of the Art, Open Problems and Performance Evaluation](http://www.iis.ee.ic.ac.uk/ComputerVision/DescrWorkshop/index.html)
workshop at ECCV 2016. It implements the *HPatches* evaluation protocol and allows to produce the result files required to enter the challenge.

[TOC]

## Overview

The *HPatches* benchmark assess local patch descriptors using a number of complementary tests. There are two ways to run such tests and enter the challenge:

1. **Comopute the patch descriptors and use HBench to compute the result files.** This is the simplest although slightly less flexible manner. In this case, one simply computes a patch descriptor for each patch in *HPatches*, stores it in a CSV file, and uses the *HBench* toolbox to generate the result files. The main limitation is that descriptors are implicitly compared using the Euclidean distance. This is explained [below](#quick).

2. **Compute the result files directly.** This method is more flexible as it allows to compare descriptors using an arbitrary method, but it requires to generate the result files directly. In particular, for each  `*.benchmark` file found in the folder hierarchy `benchmarks/`, one must provide a corresponding `*.results` file. Please refer to the individual [benchmark definitions](#benchmarks) for details.

The rest of this page discusses the first method, which relies on the *HBench* software. *HBench* provides a simple command line interface
for producing the `.results` files from descriptors stored in CSV files. *HBench* is written in MATLAB, but you do not need to own a MATLAB license as we provide a [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) which needs only on the freely available MATLAB Compiler Runtime (MCR).

<a id=quick></a>

### Entering the challenge: quick start

The simplest way to enter the challenge is to compute patch descriptor for all patches in *HPatches* and use the tools in *HBench* to produce the result files that need to be submitted. For now, you can try this on the *HPatches* training set; once the test set is released, you will be able to follow the same procedure to generate the required files.

The procedure can be summarized in a few steps:

* **Install HBench.** Download and unpack the [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) of *HBench*. Let `HBPATH` be the path to the install directory.
* **Install HPatches.** Download the [HPatches](https://github.com/featw/hpatches) dataset. You can download the dataset directly or by running the script `HBPATH/bin/run_hb.sh MCRPATH` available in the *binary* distribution of HBench (see above). Make sure that the HPatches data is unpacked in the subfolder `HBPATH/data/hpatches` of the HBench install (this can be a symlink).
* **Install the required MATLAB components.** Install either MATLAB R2016a or the free MATLAB redistributable environment [MCR R2016a](http://www.mathworks.com/products/compiler/mcr/) (see [below](#install-mcr) for details). Let `MCRPATH` be the path to either the MATLAB or MCR install. .
* **Compute the patch descriptors.** The HPatches dataset is organized in patch-images in `HBPATH/data/hpatches/SEQUENCE/IMNAME.png` (see [below](#reading-patches) for the format). For each patch-image compute the descriptor `DESCNAME` (where `DESCNAME` is an arbitrary descriptor name such as `SIFT`) and store it in a numeric [CSV file](#csv-descriptors)
`HBPATH/data/descriptors/DESCNAME/SEQUENCE/IMNAME.csv` with one descriptor per line.
* **Compute the result files.** This can be done in one go from the command line using `HBPATH/bin/run_hb.sh MCRPATH pack DESCNAME`.
This command checks the validity of descriptors, computes the results and asks for some
details about your submission. More details about the interface can be found [here](#command-line-interface).
* **Submit the results.** Send the archive `./DESCNAME_results.zip` to the [Dropbox submission folder](https://www.dropbox.com/request/2MJm7vV15XJnl1RzuCzl).

Additionally, you can also use the MATLAB code directly, using the
provided interface to compute and test baseline descriptors for comparison. You can also clone the [GIT repository](https://github.com/featw/hbench) of the *HBench* tool, but using this requires a MATLAB license.

<a id=install-mcr></a>

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

<a id=reading-patches></a>
### Reading patches

Patches are stored in large PNG files, each containing several patch instances. Each such file, identified by a `SEQUENCE` and an `IMNAME` name, is found at

```
HBPATH/data/hpatches/SEQUENCE/IMNAME.png
```

The file itself is an image 65 pixel wide and 65xN pixel high, where N is the number of stored patches. For example, the file `data/hpatches/i_ski/ref.png` contains 623 patches.

In the benchmark definitions, patches are uniquely identified by labels of the type

```
SEQUENCE.IMNAME.PATCH_IDX
```

specifying the `SEQUENCE` and `IMNAME` of the image file and the index `PATCH_INDX` of the patch in the image. Indexes start from zero. For instance `i_ski.ref.3` denotes the *fourth* patch in the `data/hpatches/i_ski/ref.png` file.

The following pseudo-code shows how to read patch `SEQUENCE.IMNAME.PATCH_IDX`:

```python
image = read_image('data/hpatches/SEQUENCE/IMNAME.png');
patch = image(start_row=PATCH_IDX*65, end_row=(PATCH_IDX+1)*65);
```

> Note: Patches with the same index has been extracted from the same location in the scene (plus some additional noise).

<a id=csv-descriptors></a>
### Creating the CSV descriptor files

Descriptors should be stored in simple comma-separated (CSV) files. These files can contain only numeric values, with one descriptor per line. All descriptors must have the same number of elements.

For example, for a patch image  `data/hpatches/i_ski/ref.png` and a `my_desc` descriptor you should generate a CSV file `data/descriptors/my_desc/i_ski/ref.csv` with 623 lines (one line per descriptor).

You can check if you have descriptors for all image files in a valid format with:

```bash
bin/run_hb.sh MCRPATH checkdesc DESCNAME
```

### Running the *HBench* tool

<a id=command-line-interface></a>

#### Command line interface

To run the *HBench* command line interface with the MCR located in the default path, run:

```bash
./bin/run_hb.sh /usr/local/MATLAB/MATLAB_Runtime/v901 COMMAND DESCNAME BENCHMARK
```

If you have MATLAB installed in `/usr/local/MATLAB/R2016a`, you can use that
instead of the MCR:

```bash
./bin/run_hb.sh /usr/local/MATLAB/R2016a COMMAND DESCNAME BENCHMARK
```
You can see the list of all available commands [here](./bin/README.md).

#### MATLAB Interface

If you have MATLAB R2016a installed, you can also easily run the `hb` function directly in MATLAB by running e.g.:

```matlab
cd HBPATH
addpath matlab
hb COMMAND DESCNAME BENCHMARK
```

Or you can experiment directly with the evaluation functions and the dataset
structures. There are few examples prepared in `matlab/example_*.m`.

#### Computing the baseline descriptors for comparison

To compute the baseline descriptors and to check if everything works as it should,
you can run:

```bash
./bin/run_hb.sh MCRPATH computedesc DESCNAME
```

Currently implemented descriptors are `sift`, `meanstd` and `resize`.

<a id=benchmarks></a>

## Benchmark definitions

The challenge consists of three common computer vision tasks. For more details about the challenges, see the following links:

* [Patch Classification Benchmark](./benchmarks/classification/README.md)
* [Image Matching Benchmkar](./benchmarks/matching/README.md)
* [Image and Patch Retrieval Benchmark](./benchmarks/retrieval/README.md)

