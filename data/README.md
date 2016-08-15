## Data folder

Folder for non-versioned data:
`hpatches` HPatches data. To download, run `download_hpatches.sh`.
Patches are organised as:
```
./data/hpatches/<sequence_name>/<image_name>.png
```
All images within the same sequence are of the same size.

`descriptors` Computed descriptors in csv format.
Descriptors are organised as:
```
./data/descriptors/<descriptor_name>/<sequence_name>/<image_name>.csv
```
And are stored in a comma-separated file where each row corresponds to a
patch from the source patch image.
