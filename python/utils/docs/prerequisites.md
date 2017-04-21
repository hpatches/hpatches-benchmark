![logo](../imgs/hpatch.png "logo") 
## Homography patches dataset 

### Prerequisites

Some extra packages are needed in order to visualise results and run the evaluation protocols. 

Installation instruction are given below per operating system.


##### Ubuntu 

From the `HPatch` root folder, run the following on a terminal
``` sh 
sudo pip install -r utils/requirements.txt
sudo apt-get install libopencv-dev python-opencv
```


##### macOS [WIP]

Install [Homebrew](http://brew.sh/)
``` sh 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

From the `HPatch` root folder, run the following on a terminal
``` sh 
brew tap homebrew/science
brew install opencv
brew install wget
sudo pip install -r utils/requirements.txt
```

##### Fedora

From the `HPatch` root folder, run the following on a terminal
``` sh 
sudo pip install -r utils/requirements.txt
yum install numpy scipy opencv*
```
