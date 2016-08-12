# HBench
A MATLAB toolbox for evalutating the HPatches - homography patches dataset.

# Image and patch references
For referring patch-images we use the following singatures:
```
sequence_name.image_name
```
where this image is stored in `./data/hpatches/sequence_name/image_name.png`.

For referring a particular patch within the image we use a signature:
```
sequence_name.image_name.patch_idx
```
Where `<patch_num>` is a zero-based index within the patches. How to get a particular patch is shown in the following pseudo-code:
``` python
image = read_image('data/hpatches/sequence_name/image_name.png');
patch = image(start_row=patch_num*65, end_row=(patch_num+1)*65);
```
Patches with the same index has been extracted from the same location in the scene (plus some additional noise) within the sequence.
