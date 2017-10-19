#!/bin/bash

base_url="http://icvl.ee.ic.ac.uk/vbalnt/hpatches"
hpatches_url="$base_url/hpatches-release.tar.gz"
descrs_url="$base_url/descriptors"
descrs_list="$base_url/descriptors/descrs.txt"
RED='\033[0;31m'
END='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: "
    echo "sh download.sh hpatches || downloads the patches dataset" 
    echo "sh download.sh descr    || returns a list of available descriptor result files"
    echo "sh download.sh descr X  || downloads computed result files for descr X"
    exit 1
fi

if [ $1 = "hpatches" ]; then
    if test -d ./data/hpatches-release
    then
	echo "The ./data/hpatches-release directory already exists."
	exit 0
    fi

    echo "\n>> Please wait, downloading the HPatches patches dataset ~4.2G\n"
    wget -O ./data/hpatches-release.tar.gz $hpatches_url
    echo ">> Please wait, extracting the HPatches patches dataset ~4.2G"
    tar -xzf ./data/hpatches-release.tar.gz -C ./data
    rm ./data/hpatches-release.tar.gz
    echo ">> Done!"
elif [ $1 = "descr" ]; then
    mkdir -p "./data/descriptors/"
    if [ $# -eq 1 ]; then
	echo "List of available descriptor results file for HPatches:"
	wget -qO- $descrs_list | cat
    elif [ $# -eq 2 ]; then
	if test -d "./data/descriptors/$2"
	then
	    echo "./data/descriptors/$2 already exists!"
	    exit 0
	else
	    echo "\n>> Please wait, downloading descriptor files for  ${RED}$2${END} \n"
	    wget -O "./data/descriptors/$2.tar.gz" "$descrs_url/$2.tar.gz"
	    echo "\n>> Extracting descriptor files for  ${RED}$2${END} \n"
	    tar -xzf "./data/descriptors/$2.tar.gz" -C ./data/descriptors
	    rm "./data/descriptors/$2.tar.gz"
	fi
    fi
fi
