# HPatches MATLAB
MATLAB implementation of the HPatches benchmark with code to reproduce the
results in [[1]](#cvpr17).

For the list of available commands run `hb help`.

  * [Requirements](#install-mcr)
  * [Command line interface](#command-line-interface)
  * [MATLAB Interface](#matlab-interface)
  * [Computing the baseline descriptors for comparison](#computing-the-baseline-descriptors-for-comparison)


### Requirements
For running the HBenchmark MATLAB interface you will need MATLAB >R2016a.

If you do not have a MATLAB license (>R2016a), you can use the command line interface from a binary package. However to run the binary package, you need to install the MATLAB Compile Runtime:

* [Download MCR for Linux 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip)
Download the zip archive, unpack and run the `./install` script.
* [Download MCR for Windows 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/win64/MCR_R2016a_win64_installer.exe)
Download and run the `.exe` installer.
* [Download MCR for Mac 64-bit](http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/maci64/MCR_R2016a_maci64_installer.zip)
Download the zip archive, unpack and run the `./install` script.

More details how to install the MCR can be found [here](http://www.mathworks.com/products/compiler/mcr/).
Please note that around 2GB of free space is required.

### Reproduce Article Results
To reproduce article results, download the used descriptor csv files and run:
```
run_article; res_article;```

This will generate figures in `results/article` (pgf/tikz format).
Scores for each descriptor are stored in `scores/scores_all`.


<a id=matlab-interface></a>
### MATLAB Interface

Main access point is the `hb` command from MATLAB:

```matlab
hb COMMAND ...
```
For more details of available commands, run `hb help`.

<a id=command-line-interface></a>
### Command line interface

To run the *HBench* command line interface on Linux with the MCR located in the default path, run:

```bash
./bin/run_hb.sh /usr/local/MATLAB/MATLAB_Runtime/v901 COMMAND ...
```

If you have MATLAB installed e.g. in `/usr/local/MATLAB/R2016a`, you can use that
instead of the MCR:

```bash
./bin/run_hb.sh /usr/local/MATLAB/R2016a COMMAND ...
```
You can see the list of all available commands [here](./bin/README.md).


<a name="cvpr17">1</a>: Vassileios Balntas, Karel Lenc, Andrea Vedaldi and Krystian Mikolajczyk: HPatches: A benchmark and evaluation of handcrafted and learned local
descriptors. In CVPR 2017.
