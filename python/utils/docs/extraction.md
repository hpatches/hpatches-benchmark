![logo](../imgs/hpatch.png "logo") 
## Homography patches dataset 

For information about relevant citations concerning patches extracted from sequences
that were not originally introduced in this dataset, please check [references](references.md).

## Patch Extraction Method

Each image sequence contains a reference image and 5 target images taken under a different illumination and/or, for a planar scenes, a different viewpoint. For all images we have the estimated ground truth homography $H$ with respect to the reference (stored in CSV files `H_ref_X` where $X=1,...,5$).

![Example sequence](../imgs/patch_extraction/images.png)
*Image 1: Example image sequence. The leftmost image is the reference image, followed by 5 images with a different viewpoint.*

Patches are sampled in the reference image using a combination of local feature extractors (Hessian, Harris and DoG detector). The patch orientation is estimated using a single major orientation using Lowe's method. No affine adaptation is used, therefore all patches are square regions in the reference image.

Patches are extracted from regions with a scale magnified by a factor of 5 compared to the original detected feature scale. Only patches for which this region is fully contained in the image are kept.

In order to prevent multiple detections at the same location, multiple detections with ellipse overlap greater than 50% are clustered and a single ellipse at random is kept. A subset of the detected patches with their measurement regions is shown in the following image:

![Example detections](../imgs/patch_extraction/detections.png)

*Image 2: Example detections in the reference image. Patches locations are visualized as ellipses. The scale of the detected patches (orange) is magnified by factor 5 to obtain the patch measurement region (yellow).*

In order to extract the patches from a target image, first an affine jitter is applied. The goal of the affine jitter is to simulate the geometric repeatability error of typical local features detector.

For easy jitter, the median ellipse overlap with the original patches is ~0.85 and for hard jitter it is ~0.72. After jittering, the frames are reprojected to the target image using the ground truth homography.

The following images show the reprojected easy/hard patches in the target image together with the extracted patches.

![Reprojected easy patches](../imgs/patch_extraction/images_easy.png)

*Image 3: Visualization of the easy patches locations in the target images.*

![Extracted easy patches](../imgs/patch_extraction/patches_easy.png)

*Image 4: Extracted easy patches from the example sequence.*

![Reprojected hard patches](../imgs/patch_extraction/images_hard.png)

*Image 5: Visualization of the hard patches locations in the target images.*

![Extracted hard patches](../imgs/patch_extraction/patches_hard.png)

*Image 6: Extracted hard patches from the example sequence.*
