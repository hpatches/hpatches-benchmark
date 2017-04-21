from glob import glob
import random
import json

# read the available sequence names
f = glob('../hpatch-release/*')
f = [k.split("/")[-1] for k in f]
i = [k for k in f if 'i_' in k]
v = [k for k in f if 'v_' in k]

# rand seeds for reproducibility
seeds = [40,41,42]
names = ['a','b','c']
# init splits dict
spl = {}

# save 3 sample train-test splits. In each split 40 sequences are kept
# for testing, and the remaining can be used for training.
for k,s in enumerate(seeds):
    random.seed(s)
    i_sam = random.sample(i,20)
    v_sam = random.sample(v,20)
    spl[names[k]] = {}
    spl[names[k]]['name'] = names[k]
    spl[names[k]]['test'] = i_sam + v_sam
    spl[names[k]]['train'] = list(set(i+v) - set(spl[names[k]]['test']))

# save the full test split
spl['full'] = {}
spl['full']['test'] = i+v
spl['full']['name'] = 'full'

# save the illumination test split
spl['illum'] = {}
spl['illum']['test'] = i
spl['illum']['name'] = 'illum'

# save the viewpoint test split
spl['view'] = {}
spl['view']['test'] = v
spl['view']['name'] = 'view'

with open('splits.json', 'w') as f:
    json.dump(spl, f,ensure_ascii=True)
        
