#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/ssh/keygen.sh)

_debug_option "$1"
generate_ssh_keys
print_details

ansible-galaxy install monolithprojects.user_management
ansible-playbook playbook.yml