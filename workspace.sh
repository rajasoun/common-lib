#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'

function create_workspace(){
  workspace=$1
  if [ ! -d $workspace ];then 
    echo -e "Creating Workspace -> $workspace"
    mkdir -p $workspace
  else 
    echo -e "${ORANGE}Workspace $workspace Already Exists${NC}"
  fi 
}

function siwtch_dir(){
  workspace=$1
  if [ ${PWD} != $workspace ];then 
    echo -e "Switching to Directory -> $workspace"
    cd $workspace
  else 
    echo -e "Already in $workspace Directory"
  fi 
}

function clone_git_repo(){
  git_repo=$1
  git_dir=$(basename $git_repo )
  if [ ! -d $workspace/$git_dir ];then 
    echo -e "Cloning Git Repository -> $git_repo"
    git clone $GIT_REPO
  else 
    echo -e "Git Repository $git_dir Already Exists"
  fi 
}

function source_scripts(){
  echo -e "Sourcing Scripts"
  base_url=$1
  source <(curl -s https://$base_url/display.sh)
  source <(curl -s https://$base_url/pre_checks.sh)
  source <(curl -s https://$base_url/setup.sh)
  source <(curl -s https://$base_url/e2e_tests.sh)
  source <(curl -s https://$base_url/teardown.sh)
}

workspace="${HOME}/workspace/test"
git_repository="https://github.com/rajasoun/mac-onboard"
script_url="raw.githubusercontent.com/rajasoun/mac-onboard/main/lib"

create_workspace $workspace
switch_dir $workspace
clone_git_repo $git_repository
switch_dir "$workspace/$git_dir"
source_scripts "$script_url"

