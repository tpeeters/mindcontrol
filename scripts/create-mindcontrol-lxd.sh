#!/bin/bash
if [[ $# -ne 1 ]] ; then
    echo "Usage:   $0 <image-name>"
    echo "Example: $0 mindcontrol"
    exit 0
fi

IMAGENAME=$1
USER="ubuntu"

function print_image_name {
    echo "The image name is $1"
}

function wait_for_network {
    echo "Waiting for $IMAGENAME to get network."
    # TODO. 10 seconds seems enough, but it is better
    #	to really check that the container is up and has network.
    sleep 15
}

function exec_as_root_in_container {
    echo "Executing \"$1\" as root in $IMAGENAME."
    lxc exec $IMAGENAME -- $1
}

function exec_as_user_in_container {
    echo "Executing \"$1\" as $USER in $IMAGENAME."
    lxc exec $IMAGENAME -- su -c "$1" -l $USER
}

print_image_name $IMAGENAME
lxc launch ubuntu:x $IMAGENAME
wait_for_network
exec_as_root_in_container "apt-get -y update"
exec_as_root_in_container "apt-get -y upgrade"
exec_as_root_in_container "apt-get -y install python3-pymongo"
exec_as_user_in_container "curl https://install.meteor.com/ | sh"
exec_as_user_in_container "git clone https://github.com/tpeeters/mindcontrol.git"
exec_as_user_in_container "cd ~/mindcontrol && git checkout mintlabs"
exec_as_user_in_container "cd ~/mindcontrol && meteor"
