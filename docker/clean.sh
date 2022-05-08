#!/usr/bin/env bash 

NC=$'\e[0m' # No Color
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'

# Displays Time in misn and seconds
function _display_time {
  local T=$1
  local D=$((T / 60 / 60 / 24))
  local H=$((T / 60 / 60 % 24))
  local M=$((T / 60 % 60))
  local S=$((T % 60))
  ((D > 0)) && printf '%d days ' $D
  ((H > 0)) && printf '%d hours ' $H
  ((M > 0)) && printf '%d minutes ' $M
  ((D > 0 || H > 0 || M > 0)) && printf 'and '
  printf '%d seconds\n' $S
}

# Displays Time in misn and seconds
function log(){
  EXIT_CODE="$1"
  MESSAGE="$2"
  if [[ -n "$EXIT_CODE" && "$EXIT_CODE" -eq 0 ]]; then
    echo -e "${GREEN}${UNDERLINE}$MESSAGE |${NC} ✅"
  else
    echo -e "${RED}${UNDERLINE}$MESSAGE |${NC} ❌"
  fi
}

function clean_running_container(){
    echo "${ORANGE}Cleaning up Running Containers${NC}"
    running_dockers=$(docker ps -q)
    if [ -n "$running_dockers" ];then
        docker kill "$(docker ps -q)" &>/dev/null
        docker rm "$(docker ps -a -q)" &>/dev/null
    fi
}

function clean_docker_images(){
    echo "${ORANGE}Cleaning up Docker Images${NC}"
    docker_images=$(docker ps -q)
    if [ -n "$docker_images" ];then
        docker rmi "$(docker images -q)" &>/dev/null
    fi
}

function system_clean(){
    echo "${ORANGE}System Clean${NC}"
    docker system prune --all --volumes --force &>/dev/null
}

_start=$(date +%s)
clean_running_container
clean_docker_images
system_clean
EXIT_CODE="$?"
_end=$(date +%s)
_runtime=$((_end-_start))
USER_NAME=$(git config --global user.name)
if [ -z $USER_NAME ];then 
  USER_NAME=$USER
fi 

MESSAGE="\nAction: Docker Clean | Duration: $(_display_time $_runtime)"
log "$EXIT_CODE" "$MESSAGE"
echo -e "\nDocker Clean for $USER_NAME  Done | $(date)\n"
