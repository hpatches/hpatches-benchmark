![logo](../imgs/hpatch.png "logo") 
## Homography patches dataset 

### Training/test splits

We provide several test and train splits, together with 
[pre-computed task files for each of the splits](../tasks/)

Currently, the splits are 

- `a` (Same as the ECCV 2016 DESCRW split)
- `b`
- `c`
- `illum`
- `view` 
- `full`: all sequences are test data


| split name          | training set | testing set |
| ------------- |:-------------:|:-------------:|
| `a` (ECCV 2016 DESCRW)     | random mix | random mix |
| `b`  | random mix | random mix |
| `c` | random mix | random mix |
| `illum` | viewpoint      | illumination |
| `view` | illumination   | viewpoint |
| `full` | -      |illumination+viewpoint |

