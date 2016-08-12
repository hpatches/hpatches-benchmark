#!/bin/bash

pushd `dirname $0` > /dev/null                                                                                                                                                               
SCRIPTPATH=`pwd`                                                                                                                                                                             

wget `cat hpatches_train.url` -P ${SCRIPTPATH}
tar xzvf ${SCRIPTPATH}/hpatches-train.tar.gz -C ${SCRIPTPATH}
