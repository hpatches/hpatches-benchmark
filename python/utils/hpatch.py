import cv2
import numpy as np
from joblib import Parallel, delayed
import multiprocessing
import pandas as pd
import json
import os

# all types of patches
tps = [
    'ref', 'e1', 'e2', 'e3', 'e4', 'e5', 'h1', 'h2', 'h3', 'h4', 'h5', 't1',
    't2', 't3', 't4', 't5'
]


def vis_patches(seq, tp, ids):
    """Visualises a set of types and indices for a sequence"""
    w = len(tp) * 65
    vis = np.empty((0, w))
    # add the first line with the patch type names
    vis_tmp = np.empty((35, 0))
    for t in tp:
        tp_patch = 255 * np.ones((35, 65))
        cv2.putText(tp_patch, t, (5, 25), cv2.FONT_HERSHEY_DUPLEX, 1, 0, 1)
        vis_tmp = np.hstack((vis_tmp, tp_patch))
    vis = np.vstack((vis, vis_tmp))
    # add the actual patches
    for idx in ids:
        vis_tmp = np.empty((65, 0))
        for t in tp:
            vis_tmp = np.hstack((vis_tmp, get_patch(seq, t, idx)))
        vis = np.vstack((vis, vis_tmp))
    return vis


def get_patch(seq, t, idx):
    """Gets a patch from a sequence with type=t and id=idx"""
    return getattr(seq, t)[idx]


def get_im(seq, t):
    """Gets a patch from a sequence with type=t and id=idx"""
    return getattr(seq, t)


def load_splits(f_splits):
    """Loads the json encoded splits"""
    with open(f_splits) as f:
        splits = json.load(f)
    return splits


def load_descrs(path, dist='L2', descr_type='', sep=','):
    """Loads *all* saved patch descriptors from a root folder"""
    print('>> Please wait, loading the descriptor files...')
    # get all folders in the descr. root folder, except the 1st which is '.'
    t = [x[0] for x in os.walk(path)][1::]
    try:
        len(t) == 116
    except Exception:
        print("%r does not seem like a valid HPatches descriptor root folder."
              % (path))
    seqs_l = Parallel(n_jobs=multiprocessing.cpu_count())(
        delayed(hpatches_descr)(f, descr_type, sep) for f in t)
    seqs = dict((l.name, l) for l in seqs_l)
    seqs['distance'] = dist
    seqs['dim'] = seqs_l[0].dim
    print('>> Descriptor files loaded.')
    return seqs


################################
# Patch and descriptor classes #
################################
class hpatches_descr:
    """Class for loading an HPatches descriptor result .csv file"""
    itr = tps

    def __init__(self, base, descr_type='', sep=','):
        self.base = base
        self.name = base.split(os.path.sep)[-1]

        for t in self.itr:
            descr_path = os.path.join(base, t + '.csv')
            df = pd.read_csv(descr_path, header=None, sep=sep).values
            df = df.astype(np.float32)
            if descr_type == "bin_packed":
                df = df.astype(np.uint8)
                df = np.unpackbits(df, axis=1)
            setattr(self, t, df)
            self.N = df.shape[0]
            self.dim = df.shape[1]
            assert self.dim != 1, \
                "Problem loading the .csv files. Please check the delimiter."


class hpatches_sequence:
    """Class for loading an HPatches sequence from a sequence folder"""
    itr = tps

    def __init__(self, base):
        name = base.split(os.path.sep)
        self.name = name[-1]
        self.base = base
        for t in self.itr:
            im_path = os.path.join(base, t + '.png')
            im = cv2.imread(im_path, 0)
            self.N = im.shape[0] / 65
            setattr(self, t, np.split(im, self.N))
