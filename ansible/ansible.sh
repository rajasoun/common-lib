#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/rajasoun/ci-shell-iaac/main/ci-shell/src/lib/os.sh)

# Returns true (0) if this the given command/app is installed and on the PATH or false (1) otherwise.
function _is_command_found {
  local -r name="$1"
  command -v "$name" >/dev/null ||
    raise_error "${RED}$name is not installed. Exiting...${NC}"
}

function generate_ssh_keys(){
    debug "Backing up $KEYS_PATH to $KEYS_PATH.bak"
    rm -fr "$KEYS_PATH.bak"
    [   -d "$KEYS_PATH" ] && mv "$KEYS_PATH" "$KEYS_PATH.bak"
    [ ! -d "$KEYS_PATH" ] && mkdir -p "$KEYS_PATH"

    echo "Generating SSH Keys for $USER_NAME"
    _is_command_found ssh-keygen
    debug "Generating SSH Keys for $USER_NAME"
    ssh-keygen -q -t rsa -N '' -f "$PRIVATE_KEY" -C "$USER_NAME@cisco.com" <<<y 2>&1 >/dev/null
    
    echo "Set File Permissions"
    # Fix Permission For Private Key
    chmod 400 "$PUBLIC_KEY"
    chmod 400 "$PRIVATE_KEY"
    debug "SSH Keys Generated Successfully"
    debug "SSH Key Scan for Cisco GitHub Successfull" 
    debug ""
    debug "========= PUBLIC KEY ============"
    debug "$(cat "$PUBLIC_KEY")"
    debug "======= END PUBLIC KEY ========="
}

# ToDo: Technical Debt : Git SSH Fix : Priority P3
function git_ssh_fix(){
    ERROR_MSG="${RED}Private SSH Key Not Present. DONT PANIC.${NC}"
    NEXT_STEP="Run ${GREEN}config${NC} again... Exiting"
      MSG="$ERROR_MSG \n $NEXT_STEP"
    [[ ! -f "$PRIVATE_KEY" ]] && echo -e "$MSG" && return 1
    # Check In Terminal
    # ssh-add -l > /dev/null || (eval $(ssh-agent -s) && ssh-add $PRIVATE_KEY)
    echo "${BOLD}Git SSH Hack Fix${NC}"
    # check if ssh key is already added
    ssh-add -l > /dev/null || echo "SSH Key "
    if [ "$(ssh-add -l | wc -l )" = 0 ]; then 
      echo "Adding SSH Key"
      eval "$(ssh-agent -s)" && ssh-add $PRIVATE_KEY
    else
      echo "${GREEN}SSH Key Already Added. Hack Fix Not Required !!!${NC}"
      ssh-add -l
    fi
  }

# Returns true (0) if this is an OS X server or false (1) otherwise.
function _os_is_darwin() {
  [[ $(uname -s) == "Darwin" ]]
}

# Replace a line of text that matches the given regular expression in a file with the given replacement.
# Only works for single-line replacements.
function _file_replace_text() {
  local -r original_text_regex="$1"
  local -r replacement_text="$2"
  local -r file="$3"

  local args=()
  args+=("-i")

  if _os_is_darwin; then
    # OS X requires an extra argument for the -i flag (which we set to empty string) which Linux does no:
    # https://stackoverflow.com/a/2321958/483528
    args+=("")
  fi

  args+=("s|$original_text_regex|$replacement_text|")
  args+=("$file")

  sed "${args[@]}" > /dev/null
}

function prepare_ansible(){
    echo "Downloading Ansible Configuration..."
    wget -q https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/config/ansible.cfg

    echo "Downloading Ansible Roles..."
    wget -q https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/requirements.yml 
    ANSIBLE_HASH_BEHAVIOUR=combine ansible-galaxy install -r requirements.yml --force

    echo "Prepare Ansible Host Inventory..."
    wget -q https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/config/hosts 
    #SSH_PRIVATE_KEY=$(cat $PRIVATE_KEY | grep -v END | grep -v BEGIN)
    _file_replace_text "_vm_name_" "$VM_NAME"  "hosts"
    _file_replace_text "_vm_ip_" "$VM_IP"  "hosts"
}

function prepare_playbook(){
    echo "Prepare Playbook..."
    wget -q https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/playbooks/$PLAYBOOK
    SSH_PUBLIC_KEY=$(cat $PUBLIC_KEY)
    _file_replace_text "_REPLACE_PUBLIC_KEY_" "$SSH_PUBLIC_KEY"  "$PLAYBOOK"
}

# Workaround for Path Limitations in Windows
function _docker() {
  export MSYS_NO_PATHCONV=1
  export MSYS2_ARG_CONV_EXCL='*'

  case "$OSTYPE" in
      *msys*|*cygwin*) os="$(uname -o)" ;;
      *) os="$(uname)";;
  esac

  if [[ "$os" == "Msys" ]] || [[ "$os" == "Cygwin" ]]; then
      # shellcheck disable=SC2230
      realdocker="$(which -a docker | grep -v "$(readlink -f "$0")" | head -1)"
      printf "%s\0" "$@" > /tmp/args.txt
      # --tty or -t requires winpty
      if grep -ZE '^--tty|^-[^-].*t|^-t.*' /tmp/args.txt; then
          #exec winpty /bin/bash -c "xargs -0a /tmp/args.txt '$realdocker'"
          winpty /bin/bash -c "xargs -0a /tmp/args.txt '$realdocker'"
          return 0
      fi
  fi
  docker "$@"
  return 0
}

function ansible_ping(){
  ansible -i hosts -m ping all
  case "$?" in
    0)
        echo "Connection SUCCESS :: Ansible Control Center -> VM ";;
    1)
        echo "Error... Ansible Control Center Can Not Reach VM via SSH" ;;
  esac
}

function configure_vm(){
  OPTS="ANSIBLE_SCP_IF_SSH=TRUE ANSIBLE_CONFIG=ansible.cfg ANSIBLE_GATHERING=smart ANSIBLE_HASH_BEHAVIOUR=combine"
  $OPTS ansible-playbook  -i hosts -v $PLAYBOOK
  case "$?" in
    0)
        echo "VM Configration SUCCESSFULL " ;;
    1)
        echo "VM Configration FAILED " ;;
  esac
}

function run_main(){
    _is_command_found "$@"
    _os_is_darwin "$@"
    _file_replace_text "$@"
    _docker "$@"

    generate_ssh_keys "$@"
    git_ssh_fix "$@"
    prepare_ansible "$@"
    ansible_ping "$@"
    configure_vm "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  if ! run_main
  then
    exit 1
  fi
fi
