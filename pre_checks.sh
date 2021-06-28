#!/usr/bin/env bash

NC=$'\e[0m' # No Color
RED=$'\e[31m'
GREEN=$'\e[32m'
ORANGE=$'\x1B[33m'

# Wrapper function for echo to stderr
function echo_std_err(){
    echo -e "$@" 1>&2
}

function check_command_exists () {
    type "$1" &> /dev/null
} 

function report_success(){
    SUCCESS=("$@")
    for cmd in "${SUCCESS[@]}"
    do
        echo "${GREEN}✔️ ${cmd} ${NC}"
    done
}

function report_failure(){
   FAILED=("$@")
   for cmd in "${FAILED[@]}"
   do
        echo "${ORANGE}❌ ${cmd} ${NC}"
   done
}

function report_results() {
    FAILED=("$@")
    if [ ${#FAILED[@]} -ne 0 ]; then
        echo_std_err "\n💥  ${RED}Failed Checks :" "${#FAILED[@]}${NC}"
        return 1
    else
        echo -e "\n${GREEN}💯  All Passed!${NC}\n"
        return 0
    fi
}

function check_pre_requisites() {
   local FAILED=()
   local SUCCESS=()
   local cmds=("$@")
   for cmd in "${cmds[@]}"
   do 
        check_command_exists "$cmd" && SUCCESS+=("$cmd") || FAILED+=("$cmd")
   done 
   report_success "${SUCCESS[@]}"
   report_failure "${FAILED[@]}"
   report_results "${FAILED[@]}"
}

function ri_success_test(){
    #source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/pre_checks.sh)
    cmds=(git make shellspec go fswatch code)
    check_pre_requisites "${cmds[@]}" 
}

function ri_failure_test(){
    #source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/pre_checks.sh)
    cmds=(git make shellspec go fswatch1 code1)
    check_pre_requisites "${cmds[@]}" 
}
