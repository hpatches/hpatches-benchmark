from utils.misc import *
import dill
import pprint
import os.path
from tabulate import tabulate as tb
import numpy as np

ft = {'e':'Easy','h':'Hard','t':'Tough'}

def results_verification(desc,splt):
    v = {'balanced':'auc','imbalanced':'ap'}
    res = dill.load(open(os.path.join("results", desc+"_verification_"+splt['name']+".p"), "rb"))
    for r in v:
        print("%s - %s variant (%s) " % (blue(desc.upper()),r.capitalize(),v[r]))
        heads = ["Noise","Inter","Intra"]
        results = []
        for t in ['e','h','t']:
            results.append([ft[t], res[t]['inter'][r][v[r]],res[t]['intra'][r][v[r]]])
        print(tb(results,headers=heads))


def results_matching(desc,splt):
    res = dill.load(open(os.path.join("results", desc+"_matching_"+splt['name']+".p"), "rb"))
    mAP = {'e':0,'h':0,'t':0}
    k_mAP = 0
    heads = [ft['e'],ft['h'],ft['t'],'mean']
    for seq in res:
        for t in ['e','h','t']:
            for idx in range(1,6):
                mAP[t] += res[seq][t][idx]['ap']
                k_mAP+=1
    k_mAP = k_mAP / 3.0
    print("%s - mAP " % (blue(desc.upper())))

    results = [mAP['e']/k_mAP,mAP['h']/k_mAP,mAP['t']/k_mAP]
    results.append(sum(results)/float(len(results)))
    print(tb([results],headers=heads))
    print("\n")


def results_retrieval(desc,splt):
    res = dill.load(open(os.path.join("results", desc+"_retrieval_"+splt['name']+".p"), "rb"))
    print("%s - mAP 10K queries " % (blue(desc.upper())))
    n_q= float(len(res.keys()))
    heads = ['']
    mAP = dict.fromkeys(['e','h','t'])
    for k in mAP:
        mAP[k] = dict.fromkeys(res[0][k])
        for psize in mAP[k]:
            mAP[k][psize] = 0

    for qid in res:
        for k in mAP:
            for psize in mAP[k]:
                mAP[k][psize] +=  res[qid][k][psize]['ap']

    results = []
    for k in ['e','h','t']:
        heads = ['Noise']+sorted(mAP[k])
        r = []
        for psize in sorted(mAP[k]):
            r.append(mAP[k][psize]/n_q)
        results.append([ft[k]]+r)

    res = np.array(results)[:,1:].astype(np.float32)
    results.append(['mean']+list(np.mean(res,axis=0)))
    print(tb(results,headers=heads))

results_methods = {
    'verification': results_verification,
    'matching': results_matching,
    'retrieval': results_retrieval
}
