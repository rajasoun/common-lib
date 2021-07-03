#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/ssh/keygen.sh)

USER_NAME="rajasoun"
PURPOSE="_dev_vm"
KEYS_PATH="ssh-keys"
PRIVATE_KEY="$KEYS_PATH/id_rsa_$USER_NAME$PURPOSE"
PUBLIC_KEY="${PRIVATE_KEY}.pub"

# Returns true (0) if this is an OS X server or false (1) otherwise.
function os_is_darwin {
  [[ $(uname -s) == "Darwin" ]]
}

# Replace a line of text that matches the given regular expression in a file with the given replacement.
# Only works for single-line replacements.
function file_replace_text {
  local -r original_text_regex="$1"
  local -r replacement_text="$2"
  local -r file="$3"

  local args=()
  args+=("-i")

  if os_is_darwin; then
    # OS X requires an extra argument for the -i flag (which we set to empty string) which Linux does no:
    # https://stackoverflow.com/a/2321958/483528
    args+=("")
  fi

  args+=("s|$original_text_regex|$replacement_text|")
  args+=("$file")

  sed "${args[@]}" > /dev/null
}


_debug_option "$1"
generate_ssh_keys
print_details

echo "Downloading Ansible Roles..."
ansible-galaxy install monolithprojects.user_management
echo "Running Playbook..."
wget https://raw.githubusercontent.com/rajasoun/common-lib/main/user/playbook.yml
SSH_PUBLIC_KEY=$(cat $PUBLIC_KEY)

file_replace_text "_REPLACE_PUBLIC_KEY_" "$SSH_PUBLIC_KEY"  "playbook.yml"
ansible-playbook playbook.yml

# usage: 
# source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/user/create_user.sh)