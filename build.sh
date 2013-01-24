#!/bin/bash

BASEDIR=$(dirname $0)

SCHEMES="$*"

if [ "$SCHEMES" == "" ]; then
    # TODO: This is the output of 'xcodebuild -list'. automate it.
    SCHEMES="Rome Venice Munich Sachsenhausen Paris Amsterdam Berlin Alhambra Prague London Geneva Edinburgh"
    echo "building all: $SCHEMES"
fi

for scheme in $SCHEMES; do

    PRODUCT_NAME=$scheme
    cmd="xcodebuild -scheme $scheme archive || exit -1"
    echo $cmd
    eval $cmd

    source "$BASEDIR/testflight-upload.sh"
    
done
