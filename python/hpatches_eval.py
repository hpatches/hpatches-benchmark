"""Evaluation code for the HPatches homography patches dataset.

Usage:
  hpatches_eval.py (-h | --help)
  hpatches_eval.py --version
  hpatches_eval.py --descr-name=<> --task=<>... [--descr-dir=<>] [--results-dir=<>] [--split=<>] [--dist=<>] [--delimiter=<>] [--pcapl=<>]

Options:
  -h --help         Show this screen.
  --version         Show version.
  --descr-name=<>   Descriptor name, e.g. sift
  --descr-dir=<>    Descriptor results root folder. [default: {root}/data/descriptors]
  --results-dir=<>  Results root folder. [default: results]
  --task=<>         Task name. Valid tasks are {verification,matching,retrieval}.
  --split=<>        Split name. Valid are {a,b,c,full,illum,view}. [default: a]
  --dist=<>         Distance name. Valid are {L1,L2}. [default: L2]
  --delimiter=<>    Delimiter used in the csv files. [default: ,]
  --pcapl=<>        Compute results for pca-power law descr. [default: no]

For more visit: https://github.com/hpatches/
"""
from utils.hpatch import *
from utils.tasks import *
from utils.misc import *
from utils.docopt import docopt
import os
import time
import dill

if __name__ == '__main__':
    opts = docopt(__doc__, version='HPatches 1.0')
    descr_dir = opts['--descr-dir'].format(
        root=os.path.normpath(os.path.join(os.path.abspath(os.path.dirname(__file__)), ".."))
    )
    path = os.path.join(descr_dir, opts['--descr-name'])

    try:
        assert os.path.exists(path)
    except:
       print("%r does not exist." % (path))
       exit(0)

    results_dir = opts['--results-dir']
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)

    descr_name = opts['--descr-name']
    print('\n>> Running HPatch evaluation for %s' % blue(descr_name))

    descr = load_descrs(path,dist=opts['--dist'],sep=opts['--delimiter'])

    with open(os.path.join(tskdir, "splits", "splits.json")) as f:
        splits = json.load(f)

    splt = splits[opts['--split']]

    for t in opts['--task']:
        res_path = os.path.join(results_dir, descr_name+"_"+t+"_"+splt['name']+".p")
        if os.path.exists(res_path):
            print("Results for the %s, %s task, split %s, already cached!" %\
                  (descr_name,t,splt['name']))
        else:
            res = methods[t](descr,splt)
            dill.dump(res, open(res_path, "wb"))

    # do the PCA/power-law evaluation if wanted
    if opts['--pcapl']!='no':
        print('>> Running evaluation for %s normalisation' % blue("pca/power-law"))
        compute_pcapl(descr,splt)
        for t in opts['--task']:
            res_path = os.path.join(results_dir, descr_name+"_pcapl_"+t+"_"+splt['name']+".p")
            if os.path.exists(res_path):
                print("Results for the %s, %s task, split %s,PCA/PL already cached!" %\
                      (descr_name,t,splt['name']))
            else:
                res = methods[t](descr,splt)
                dill.dump(res, open(res_path, "wb"))
