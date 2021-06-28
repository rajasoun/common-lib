#!/usr/bin/env bash

NC=$'\e[0m' # No Color
RED=$'\e[31m'
GREEN=$'\e[32m'
ORANGE=$'\x1B[33m'

# Wrapper function for echo to stderr
function echo_std_err(){
    echo "$@" 1>&2
}

function check_command_exists () {
    type "$1" &> /dev/null ;
} 

function report_results() {
    FAILED=("$@")
    if [ ${#FAILED[@]} -ne 0 ]; then
        echo_std_err "\n💥  ${RED}Failed tests:" "${#FAILED[@]}${NC}"
        echo "${ORANGE}${FAILED[@]} Not Found ${NC}\n" 
        return 1
    else
        echo  "${GREEN}\n💯  All Passed!${NC}\n"
        return 0
    fi
}

function check_pre_requisites() {
   local FAILED=()
   local cmds=("$@")
   for cmd in "${cmds[@]}"
   do 
        (check_command_exists "$cmd"  && echo "${GREEN}✅ $cmd ${NC}" ) || FAILED+=("$cmd")
   done 
   report_results "${FAILED[@]}"
}

