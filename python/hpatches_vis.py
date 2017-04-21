from utils.hpatch import *
import cv2 

# select a subset of types of patches to visualise
# tp = ['ref','e5','h5','t5']
#or visualise all - tps holds all possible types
tp = tps

# list of patch indices to visualise
ids = range(10)

# load a sample sequence
seq = hpatch_sequence('../data/hpatches-release/v_dogman/')
vis = vis_patches(seq,tp,ids)

# show 
cv2.imshow("HPatches example", vis/255)
cv2.waitKey(0)

# or save
# cv2.imwrite("patches.png", vis)
