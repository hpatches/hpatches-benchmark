# HBench
A MATLAB toolbox for evaluating common computer vision tasks with the HPatches dataset. This code implements the challenge for the [Local Features: State of the Art, Open Problems and Performance Evaluation](http://www.iis.ee.ic.ac.uk/ComputerVision/DescrWorkshop/index.html) workshop at ECCV 2016.

## Tasks
The challenge consists of three common computer vision tasks. For more details about them, please follow the links:
* [Patch Classification](./benchmarks/classification/README.md)
* [Image Matching](./benchmarks/matching/README.md)
* [Image and Patch Retrieval](./benchmarks/retrieval/README.md)

## Getting started

## Command Line Interface

## MATLAB Interface

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
