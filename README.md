# HBench
A toolbox for evaluating local feature descriptors in common computer vision tasks with the *HPatches* dataset (Homography patches).
This toolbox is a support code for the challenge for
[Local Features: State of the Art, Open Problems and Performance Evaluation](http://www.iis.ee.ic.ac.uk/ComputerVision/DescrWorkshop/index.html)
workshop at ECCV 2016.

## Getting started
In order to take part in the challenge, one needs to send the archived `*.results`
files for each `*.benchmark` file in the `benchmarks/` sub-folders. To do
so, the simplest way is to use this toolbox.

*HBench* is written in MATLAB but provides a simple command line interface
for producing the `.results` files from descriptors stored in CSV files. You do not need to own a MATLAB license as we provide a [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) which needs only on the freely available MATLAB Compiler Runtime (MCR)

### Participate in the challange
To obtain the results files, once the test set is released, you generally proceed as follows:
* Donwload and unpack the [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz) of *HBench*. If you do not have MATLAB R2016a, install [MCR R2016a](http://www.mathworks.com/products/compiler/mcr/) to some `MCRPATH`. Otherwise `MCRPATH` is your MATLAB path. See [Install MCR](#install-mcr) for more details.
* Download the *HPatches* dataset. The dataset is organized in patch-images in `data/hpatches/SEQUENCE/IMNAME.png`.
You can download the dataset by running `bin/run_hb.sh MCRPATH`. The script `run_hb.sh` is only in the [binary distribution](https://dl.dropboxusercontent.com/u/555392/hbench-v0.1.tar.gz).
* For each patch-image compute the descriptor DESCNAME and store it in a numeric [CSV file](#csv-descriptors)
`data/descriptors/DESCNAME/SEQUENCE/IMNAME.csv` with one descriptor per line.
* Compute the results for all the tasks with `./bin/run_hb.sh MCRPATH pack DESCNAME`.
It checks the validity of descriptors, computes the results and asks for some
details about your submission. More details about the interface [here](#command-line-interface).
* Send the archive `./DESCNAME_results.zip` to the [Dropbox submission folder](https://www.dropbox.com/request/2MJm7vV15XJnl1RzuCzl).

Additionally you can also experiment with the MATLAB code directly, using the
provided interface to compute your own descriptors. You can also clone the
[GIT repository](https://github.com/featw/hbench), however to run the source code you need a MATLAB license.

### Install MCR
The binary command line interface needs either MATLAB R2016a installed or the MCR installed.
If you do not have MATLAB installed, you can download the MCR for:
* [Download MCR for Linux 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip)
Download the zip archive, unpack and run the `./install` script.
* [Download MCR for Windows 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/win64/MCR_R2016a_win64_installer.exe)
Download and run the `.exe` installer.
* [Download MCR for Mac 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/maci64/MCR_R2016a_maci64_installer.zip)
Download the zip archive, unpack and run the `./install` script.

More details how to install the MCR can be found [here](http://www.mathworks.com/products/compiler/mcr/).
Please note that around 2GB of free space is required.

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

You can see the list of all available commands [here](./bin/README.md). The command
line interface works only with MATLAB R2016a, if you have an older version,
you can still use the [MATLAB interface](matlab-interface).

### MATLAB Interface
If you have MATLAB >R2014b installed, you can also easily run the `hb` function directly in MATLAB by running e.g.:
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

## Tasks
The challenge consists of three common computer vision tasks.
For more details about the challenges, see the following links:
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
