# HBench
A toolbox for evaluating common computer vision tasks with the HPatches dataset.
This code implements the challenge for the
[Local Features: State of the Art, Open Problems and Performance Evaluation](http://www.iis.ee.ic.ac.uk/ComputerVision/DescrWorkshop/index.html)
workshop at ECCV 2016.

## Getting started
In order to take part in the challenge, one needs to send the the `*.results`
files for each `*.benchmark` file in the `./benchmarks/` directory. To do
so, the easiest way is to use the provided HBench toolbox.

The HBench is written in MATLAB but provides a simple command line interface
for computing the results tasks. If you do not own a license to MATLAB, you
can also use the freely available MATLAB compiler runtime (MCR).

### Participate in the challange
To obtain the results files you generally proceed as follows:
* Install [MATLAB Compiler Runtime](http://www.mathworks.com/products/compiler/mcr/) to `MCRPATH`.
* Download the HPatches dataset, stored in patch-images `./data/hpatches/<seqquence>/<patchimage>.png`.
e.g. with the command line interface by running `./bin/hb_run.sh MCRPATH`
* For each patch-image compute the descriptor and store it in a CSV file
`./data/descriptors/DESCNAME/<seq_name>/<patchimage>.csv` with one
descriptor per line. E.g. for a patch image  `./data/datasets/i_ski/ref.png` and a SURF descriptor there will be a csv file `./data/descriptors/surf/i_ski/ref.csv` with 623 lines (one line per descriptor).
* Run all the tasks `./bin/hb_run.sh MCRPATH pack DESCNAME`. This also checks the validity of your descriptors.
* Send the archive `./DESCNAME_results.zip` to the [submission folder](https://www.dropbox.com/request/2MJm7vV15XJnl1RzuCzl).

To see details how to use the command line interface, see the [Command Line Interface](#Command line interface).

Additionally you can also experiment with the MATLAB code directly, using the
provided interface to compute your own descriptors.

### Install MCR
The command line interface needs either MATLAB R2016a installed or the MCR installed.
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
To run the HBenchmarks command line interface with the MCR located in the default path, run:
``` bash
./bin/run_hb.sh /usr/local/MATLAB/MATLAB_Runtime/v901 COMMAND DESCNAME BENCHMARK
```
If you have MATLAB installed in `/usr/local/MATLAB/R2016a`, you can use that
instead of the MCR:
``` bash
./bin/run_hb.sh /usr/local/MATLAB/R2016a COMMAND DESCNAME BENCHMARK
```

### MATLAB Interface
If you have MATLAB R2016a installed, you can also easily run the `hb` function directly in MATLAB by running e.g.:
``` bash
cd matlab
hb COMMAND DESCNAME BENCHMARK
```

### Compute Baseline Descriptors
To compute the baseline descriptors and to check if everything works as it should,
you can run:
```
./bin/run_hb.sh MCRPATH computedesc DESCNAME
```
Currently implemented descriptors are `meanstd` and `resize`.

You can see the list of all available commands [here](./bin/README.md).

## Tasks
The challenge consists of three common computer vision tasks.
For more details about the challenges, see the following links:
* [Patch Classification](./benchmarks/classification/README.md)
* [Image Matching](./benchmarks/matching/README.md)
* [Image and Patch Retrieval](./benchmarks/retrieval/README.md)

## Referencing patch-images and patches
For referring patch-images we use the following signatures:
```
sequence_name.image_name
```
where the image is stored in `./data/hpatches/sequence_name/image_name.png`.

For referring a particular patch within the image we use a signature:
```
sequence_name.image_name.patch_idx
```
Where `patch_idx` is a zero-based index within the patches. How to get a particular patch is shown in the following pseudo-code:
``` python
image = read_image('data/hpatches/sequence_name/image_name.png');
patch = image(start_row=patch_num*65, end_row=(patch_num+1)*65);
```
Patches with the same index has been extracted from the same location in the scene (plus some additional noise) within the sequence.
