# bin/hb_run.sh MCRPATH HPatches command line interface
`bin/hb_run.sh MCRPATH help`
Print this help string.
`bin/hb_run.sh MCRPATH help COMMAND`
Print a help string for a COMMAND.
 
`bin/hb_run.sh MCRPATH dataset`
Provision the HPatches dataset to `<hb_root>/data/hpatches_v1.1/`.
 
`bin/hb_run.sh MCRPATH computedesc DESCNAME`
Compute descriptor DESCNAME for patch images stored in
`<hb_root>/data/hpatches_v1.1/`. Supported descriptors are:
 
* sift, rootsift, meanstd, resize
 
For your own descriptor, add a function DESCNAME to
+desc/+feats/DESCNAME.m
 
`bin/hb_run.sh MCRPATH all DESCNAME`
`bin/hb_run.sh MCRPATH verification | matching | retrieval DESCNAME`
Run all or selected benchmarks for a descriptor DESCNAME.
Descriptor must be stored in `<hb_root>/data/descriptors/DESCNAME/`
as  `SEQ_NAME/IMNAME.csv` in comma separated files (one descriptor
per line).
By default, stores the results in CSV files in:
`<hb_root>/scores/<DESCNAME>/<BENCHNAME>.csv`
If tresults file exist, the computation is skipped. Use
`'override', true'` to overwrite existing score files. You can change
the scores path with the `'scoresroot', 'newpath'` option.
 
You can additionally configure the descriptor normalisation
with `'norm', true`, see `hb help norm` for additional arguments.

