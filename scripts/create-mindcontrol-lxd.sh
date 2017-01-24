#!/bin/bash
if [[ $# -ne 1 ]] ; then
    echo "Usage:   $0 <container-name>"
    echo "Example: $0 mindcontrol"
    exit 0
fi

CONTAINER=$1
USER="ubuntu"

function print_container_name {
    echo "The container name is $1"
}

function wait_for_network {
    echo "Waiting for $CONTAINER to get network."
    # TODO. 10 seconds seems enough, but it is better
    #	to really check that the container is up and has network.
    sleep 15
}

function exec_as_root_in_container {
    echo "Executing \"$1\" as root in $CONTAINER."
    lxc exec $CONTAINER -- $1
}

function exec_as_user_in_container {
    echo "Executing \"$1\" as $USER in $CONTAINER."
    lxc exec $CONTAINER -- su -c "$1" -l $USER
}

print_container_name $CONTAINER
lxc launch ubuntu:x $CONTAINER
wait_for_network
exec_as_root_in_container "apt-get -y update"
exec_as_root_in_container "apt-get -y upgrade"
exec_as_root_in_container "apt-get -y install python3-pymongo"
exec_as_user_in_container "curl https://install.meteor.com/ | sh"
exec_as_user_in_container "git clone https://github.com/tpeeters/mindcontrol.git"
exec_as_user_in_container "cd ~/mindcontrol && git checkout mintlabs"
exec_as_user_in_container "cd ~/mindcontrol && meteor"
