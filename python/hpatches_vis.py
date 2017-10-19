from utils.hpatch import *
import cv2 


# all types of patches 
tps = ['ref','e1','e3','e5','h1','h3','h5',\
       't1','t3','t5']

def vis_patches(seq,tp,ids):
    """Visualises a set of types and indices for a sequence"""
    h = len(tp)*65
    vis = np.empty((h, 0))
    # add the first column with the patch type names
    vis_tmp = np.empty((0,55))
    for t in tp:
        tp_patch = 255*np.ones((65,55))
        cv2.putText(tp_patch,t,(5,25),cv2.FONT_HERSHEY_DUPLEX , 1,0,1)                       
        vis_tmp = np.vstack((vis_tmp,tp_patch))
    vis = np.hstack((vis,vis_tmp))
    # add the actual patches
    for idx in ids:
        vis_tmp = np.empty((0,65))
        for t in tp:
            vis_tmp = np.vstack((vis_tmp,get_patch(seq,t,idx)))
        vis = np.hstack((vis,vis_tmp))
    return vis


# select a subset of types of patches to visualise
# tp = ['ref','e5','h5','t5']
#or visualise all - tps holds all possible types
tp = tps

# list of patch indices to visualise
ids = range(1,55)

# load a sample sequence
seq = hpatch_sequence('../data/hpatches-release/v_calder/')
vis = vis_patches(seq,tp,ids)

# show 
# cv2.imshow("HPatches example", vis/255)
# cv2.waitKey(0)

# or save
cv2.imwrite("patches.png", vis)
