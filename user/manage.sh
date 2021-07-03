#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/ansible.sh)

if [ $# -le "2" ]; then
   raise_error "Usage: $0 <vm_name> <vm_ip> <playbook_name.yml>" 
fi

VM_NAME=$1
VM_IP=$2
PLAYBOOK=$3

DEBUG_OFF="" 
DEBUG_TOGGLE="${4:-$DEBUG_OFF}"
_debug_option "$DEBUG_TOGGLE"

USER_NAME="ubuntu"
PURPOSE="_dev_vm"

KEYS_PATH="ssh-keys"
PRIVATE_KEY="$KEYS_PATH/id_rsa_$USER_NAME$PURPOSE"
PUBLIC_KEY="${PRIVATE_KEY}.pub"

ANSIBLE_BASE_PATH="ansible"
CONFIG_BASE_PATH="config"

generate_ssh_keys 
git_ssh_fix
prepare_ansible $USER_NAME
ansible_ping 
configure_vm 
rm -fr *.yml *.cfg ssh-keys ssh-keys*.* config roles