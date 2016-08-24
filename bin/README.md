# HBenchmarks command line interface
`bin/hb_run.sh MCRPATH COMMAND DESCNAME BENCHMARKNAME` Is a general call of the HBenchmarks
   command line interface. The supported opts.alltasks are:
 
`bin/hb_run.sh MCRPATH checkdesc DESCNAME`  
Check the validity of the descriptors located in:
data/descriptors/DESCNAME/<sequence_name>/<patchimage>.csv

`bin/hb_run.sh MCRPATH pack DESCNAME`  
Run evaluation on all benchmark files defined in `./benchmarks/` and
pack the results to `DESCNAME_results.zip`.
Descriptors `DESCNAME` **must** be stored in an appropriate folders.
This opts.alltasks computes the results only for tasks, where the results
file does not exist. To recompute all the results, call:
```
bin/hb_run.sh MCRPATH pack DESCNAME * override true
```
or delete the appropriate `.results` file.
This command also makes sure that the submission name and contact
email address are stored in `data/descriptors/DESCNAME/info.txt`.
 
Please note that the classification benchmark loads the descriptors to
memory.

`bin/hb_run.sh MCRPATH computedesc DESCNAME`  
Compute some of the provided baseline descriptors. Supported
descriptors currently are:
* `sift`- SIFT descriptor (VLFeat implementation)
* `meanstd`  - 2D descriptor with mean and standard deviation of a patch
* `resize`   - resize patch into 4x4 patch and perform meanstd norm.
 
`bin/hb_run.sh MCRPATH TASK DESCNAME BENCHMARKNAME`  
Compute results only for a specified .benchmark file stored in:
```
benchmarks/TASK/BENCHMARKNAME.benchmark
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
 
`bin/hb_run.sh MCRPATH packdesc DESCNAME`  
Pack all the descriptors DESCNAME to `DESCNAME_descriptors.zip`.
 
`bin/hb_run.sh MCRPATH help`  
Print this help string.

