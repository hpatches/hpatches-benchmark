"""Code for printing/plotting results for the HPatches evaluation protocols.

Usage:
  hpatches_results.py (-h | --help)
  hpatches_results.py --version
  hpatches_results.py --descr-name=<>...
                      [--results-dir=<>] [--split=<>] [--pcapl=<>]

Options:
  -h --help         Show this screen.
  --version         Show version.
  --descr-name=<>   Descriptor name e.g. --descr=sift.
  --results-dir=<>  Results root folder. [default: results]
  --split=<>        Split name. Valid are {a,b,c,full,illum,view}. [default: a]

For more visit: https://github.com/hpatches/
"""
from utils.tasks import tskdir
from utils.results import plot_hpatches_results
from utils.results import DescriptorHPatchesResult
import os.path
import json
from utils.docopt import docopt

if __name__ == '__main__':
    opts = docopt(__doc__, version='HPatches 1.0')
    descrs = opts['--descr-name']

    with open(os.path.join(tskdir, "splits", "splits.json")) as f:
        splits = json.load(f)
    splt = splits[opts['--split']]

    hpatches_results = []
    for desc in descrs:
        hpatches_results.append(DescriptorHPatchesResult(desc, splt))

    plot_hpatches_results(hpatches_results)
