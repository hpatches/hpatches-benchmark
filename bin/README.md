# HBench command line interface

`bin/hb_run.sh MCRPATH COMMAND DESCNAME BENCHMARKNAME` Is a general call of the HBench
   command line interface. The supported commands are:

### `checkdesc`  - Check descriptor validity
`bin/hb_run.sh MCRPATH checkdesc DESCNAME`  
Check the validity of the descriptors located in:
`HBPATH/data/descriptors/DESCNAME/<sequence_name>/<patchimage>.csv`

### `pack` - Run benchmarks and pack results

`bin/hb_run.sh MCRPATH pack DESCNAME`  
evaluates all benchmark files `*.benchmark` located in the `HBENCH/benchmarks/` folder hierarchy and
pack the results to `DESCNAME_results.zip`.
The descriptors `DESCNAME` **must** be stored in an appropriate folders as shown above.
This commands computes the results only for those benchmark for which the corresponding `*.results` file does not exist yet. To force recomputing all the result files, call:
```
bin/hb_run.sh MCRPATH pack DESCNAME * override true
```
or delete the appropriate `*.results` files.
This command also makes sure that the submission name and contact
email address are stored in `HBPATH/data/descriptors/DESCNAME/info.txt`.
 
Please note that the classification benchmark loads the descriptors to memory, which requires several GBs of RAM.

### `computedesc` - Compute baseline descriptors

`bin/hb_run.sh MCRPATH computedesc DESCNAME`  
Compute some of the provided baseline descriptors. The supported
descriptors currently are:
* `meanstd`  - a 2D descriptor consisting of the mean and standard deviation of the pixels in a patch.
* `resize`   - a 16D descriptor with the pixels of the patch resized to a 4x4 square and then normalized by mean subtraction and division by the standard deviation.

### `TASK` - Evaluate a specific benchmark

`bin/hb_run.sh MCRPATH TASK DESCNAME BENCHMARKNAME`  
Compute results only for a specified `*.benchmark` file stored in:
```
HBENCH/benchmarks/TASK/BENCHMARKNAME.benchmark
```
And TASK is one of `classification`, `retrieval` or `matching`.
BENCHMARKNAME can contain an asterisk `*` wildcard. E.g. to run all
train retrieval task, call:
```
bin/hb_run.sh MCRPATH retrieval DESCNAME train_*
```
This always overwrites existing results files. Results will be stored
in:
```
results/DESCNAME/retrieval/BENCHMARKNAME.results
```
 
Please note that the classification benchmark caches descriptors in
memory.

### `packdesc` - Pack descriptors

`bin/hb_run.sh MCRPATH packdesc DESCNAME`  
Pack all the descriptors DESCNAME to `DESCNAME_descriptors.zip`.
 
### `help` - Print help

`bin/hb_run.sh MCRPATH help`  
Print this help string.

