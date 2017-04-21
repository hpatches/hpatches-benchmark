import numpy as np

# TODO: add documentation

def tpfp(scores,labels,numpos=None):
    # count labels
    p = int(np.sum(labels))
    n = len(labels)-p

    if numpos is not None:
        assert(numpos>=p), \
            'numpos smaller that number of positives in labels'
        extra_pos = numpos-p
        p = numpos
        scores = np.hstack((scores,np.repeat(-np.inf, extra_pos)))
        labels = np.hstack((labels,np.repeat(1, extra_pos)))
    
    perm = np.argsort(-scores, kind='mergesort',axis=0)
    
    scores = scores[perm]
    # assume that data with -INF score is never retrieved
    stop = np.max(np.where(scores > -np.inf))

    perm = perm[0:stop+1]

    labels = labels[perm]
    # accumulate true positives and false positives by scores    
    tp = np.hstack((0, np.cumsum(labels == 1)))
    fp = np.hstack((0, np.cumsum(labels == 0)))

    return tp,fp,p,n,perm

def pr(scores,labels,numpos=None):
    [tp,fp,p,n,perm] = tpfp(scores,labels,numpos)
    
    # compute precision and recall
    small = 1e-10
    recall = tp / float(np.maximum(p, small))
    precision = np.maximum(tp, small) / np.maximum(tp+fp, small)

    return precision,recall,np.trapz(precision,recall)


def roc(scores,labels,numpos=None):
    [tp,fp,p,n,perm] = tpfp(scores,labels,numpos)
    
    # compute tpr and fpr
    small = 1e-10
    tpr = tp / float(np.maximum(p, small))
    fpr = fp / float(np.maximum(n, small))

    return fpr,tpr,np.trapz(tpr,fpr)
