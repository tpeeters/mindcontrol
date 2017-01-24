#!/bin/bash
if [[ $# -ne 3 ]] ; then
    echo "Usage:   $0 <container-name> <image-url> <image-name>"
    echo "Example: $0 xenial-mindcontrol http://localhost:8000/T1.nii.gz myt1"
    exit 0
fi

CONTAINER=$1
USER="ubuntu"
IMAGEURL=$2
IMAGENAME=$3

function exec_as_user_in_container {
    echo "Executing \"$1\" as $USER in $CONTAINER."
    lxc exec $CONTAINER -- su -c "$1" -l $USER
}

exec_as_user_in_container "cd ~/mindcontrol/imports/python_generate && python3 fill_db.py -i $IMAGEURL -n $IMAGENAME -e mintlabs"
