#!/usr/bin/env bash   

USER_NAME="test"
PURPOSE="_dev_vm"
KEYS_PATH="ssh-keys"
PRIVATE_KEY="$KEYS_PATH/id_rsa_$USER_NAME$PURPOSE"
PUBLIC_KEY="${PRIVATE_KEY}.pub"

source <(curl -s https://raw.githubusercontent.com/rajasoun/ci-shell-iaac/main/ci-shell/src/lib/os.sh)

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
}

function print_details(){
  debug ""
  debug "========= PUBLIC KEY ============"
  debug "$(cat "$PUBLIC_KEY")"
  debug "======= END PUBLIC KEY ========="
}

# _debug_option "$1"
# generate_ssh_keys
# print_details

