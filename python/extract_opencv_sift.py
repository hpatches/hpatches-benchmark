import sys
import argparse
import time
import os
import sys
import cv2
import math
import numpy as np
from tqdm import tqdm
from copy import deepcopy
import random
import time
import numpy as np
import glob
import os

assert len(sys.argv)==3, "Usage python extract_opencv_sift.py hpatches_db_root_folder 65"
OUT_W = int(sys.argv[2])
# all types of patches 
tps = ['ref','e1','e2','e3','e4','e5','h1','h2','h3','h4','h5',\
       't1','t2','t3','t4','t5']

class hpatches_sequence:
    """Class for loading an HPatches sequence from a sequence folder"""
    itr = tps
    def __init__(self,base):
        name = base.split('/')
        self.name = name[-1]
        self.base = base
        for t in self.itr:
            im_path = os.path.join(base, t+'.png')
            im = cv2.imread(im_path,0)
            self.N = im.shape[0]/65
            setattr(self, t, np.split(im, self.N))


seqs = glob.glob(sys.argv[1]+'/*')
seqs = [os.path.abspath(p) for p in seqs]

descr_name = 'opencv-sift-'+str(OUT_W)
sift1 = cv2.xfeatures2d.SIFT_create()

def get_center_kp(PS=65.):
    c = PS/2.0
    center_kp = cv2.KeyPoint()
    center_kp.pt = (c,c)
    center_kp.size = 2*c/5.303
    return center_kp

ckp = get_center_kp(OUT_W)

for seq_path in seqs:
    seq = hpatches_sequence(seq_path)
    path = os.path.join(descr_name,seq.name)
    if not os.path.exists(path):
        os.makedirs(path)
    descr = np.zeros((int(seq.N),int(128))) # trivial (mi,sigma) descriptor
    for tp in tps:
        print(seq.name+'/'+tp)
        if os.path.isfile(os.path.join(path,tp+'.csv')):
            continue
        n_patches = 0
        for i,patch in enumerate(getattr(seq, tp)):
            n_patches+=1
        t = time.time()
        patches_resized = np.zeros((n_patches, 1, OUT_W, OUT_W)).astype(np.uint8)
        if OUT_W != 65:
            for i,patch in enumerate(getattr(seq, tp)):
                patches_resized[i,0,:,:] = cv2.resize(patch,(OUT_W,OUT_W))
        else:
            for i,patch in enumerate(getattr(seq, tp)):
                patches_resized[i,0,:,:] = patch
        outs = []
        bs = 1;
        n_batches = n_patches / bs
        for batch_idx in range(int(n_batches)):
            if batch_idx == n_batches - 1:
                if (batch_idx + 1) * bs > n_patches:
                    end = n_patches
                else:
                    end = (batch_idx + 1) * bs
            else:
                end = (batch_idx + 1) * bs
            data_a = patches_resized[batch_idx * bs: end, :, :, :]
            outs.append(sift1.compute(data_a[0,0],[ckp])[1][0].reshape(-1, 128))
        res_desc = np.concatenate(outs)
        res_desc = np.reshape(res_desc, (n_patches, -1))
        out = np.reshape(res_desc, (n_patches,-1))
        np.savetxt(os.path.join(path,tp+'.csv'), out, delimiter=',', fmt='%10.5f')
