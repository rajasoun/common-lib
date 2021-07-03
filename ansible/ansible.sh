#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/rajasoun/ci-shell-iaac/main/ci-shell/src/lib/os.sh)

if [ $# -le "2" ]; then
   raise_error "Usage: $0 <vm_name> <vm_ip>" 
fi

VM_NAME=$1
VM_IP=$2

USER_NAME="ubuntu"
PURPOSE="_dev_vm"

SSH_KEYS_PATH="ssh-keys"
PRIVATE_KEY="$SSH_KEYS_PATH/id_rsa_$USER_NAME$PURPOSE"
PUBLIC_KEY="${PRIVATE_KEY}.pub"

ANSIBLE_BASE_PATH="ansible"
CONFIG_BASE_PATH="config"

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

# Returns true (0) if this is an OS X server or false (1) otherwise.
function os_is_darwin() {
  [[ $(uname -s) == "Darwin" ]]
}

# Replace a line of text that matches the given regular expression in a file with the given replacement.
# Only works for single-line replacements.
function file_replace_text() {
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

function prepare_ansible(){
    echo "Downloading Ansible Roles..."
    wget https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/requirements.yml 
    ansible-galaxy install -r requirements.yml --force

    echo "Prepare Playbook..."
    wget https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/users.yml
    SSH_PUBLIC_KEY=$(cat $PUBLIC_KEY)
    file_replace_text "_REPLACE_PUBLIC_KEY_" "$SSH_PUBLIC_KEY"  "users.yml"

    echo "Prepare Ansible Host Inventory..."
    mkdir -p config
    wget -O https://raw.githubusercontent.com/rajasoun/common-lib/main/ansible/hosts "config/hosts"
    SSH_PRIVATE_KEY=$(cat $PRIVATE_KEY)
    file_replace_text "_REPLACE_PRIVATE_KEY_" "$SSH_PRIVATE_KEY"  "config/hosts"
    file_replace_text "_vm_name_" "$VM_NAME"  "config/hosts"
    file_replace_text "_vm_ip_" "$VM_IP"  "config/hosts"
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
  CMD="ansible -i /config/hosts -m ping all"
  _docker run --rm -it --user ansible --name ansible_ping \
            -v "${PWD}/$SSH_KEYS_PATH":/keys \
            -v "${PWD}":/ansible \
            -v "${PWD}/$CONFIG_BASE_PATH":/config \
            cytopia/ansible:latest-tools bash -c "$CMD"

  case "$?" in
    0)
        echo "Connection SUCCESS :: Ansible Control Center -> VM ";;
    1)
        echo "Error... Ansible Control Center Can Not Reach VM via SSH" ;;
  esac
}

function configure_vm(){
  PLAYBOOK="/ansible/$1"
  OPTS="ANSIBLE_SCP_IF_SSH=TRUE ANSIBLE_CONFIG=/ansible/ansible.cfg ANSIBLE_GATHERING=smart"
  CONFIGURE="$OPTS ansible-playbook  -i /config/hosts -v $PLAYBOOK"

  CMD="$CONFIGURE"

  _docker run --rm -it --user ansible --name ansible_configure_vm \
            -v "${PWD}/$SSH_KEYS_PATH":/keys \
            -v "${PWD}/$ANSIBLE_BASE_PATH":/ansible \
            -v "${PWD}/$CONFIG_BASE_PATH":/config \
            cytopia/ansible:latest-tools bash -c "$CMD"

  case "$?" in
    0)
        echo "VM Configration SUCCESSFULL " ;;
    1)
        echo "VM Configration FAILED " ;;
  esac
}

function run_main(){
    _is_command_found "$@"
    generate_ssh_keys "$@"
    print_details "$@"
    os_is_darwin "$@"
    file_replace_text "$@"
    ansible_ping "$@"
    prepare_ansible "$@"
    configure_vm "$@"
    _docker "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  if ! run_main
  then
    exit 1
  fi
fi