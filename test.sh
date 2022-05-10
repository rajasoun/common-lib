#!/usr/bin/env bash

workspace="${HOME}/workspace/test"
mkdir -p $workspace
cd $workspace
git clone https://github.com/rajasoun/mac-onboard
cd "$workspace/mac-onboard"
pwd
ls -als 
cd $workspace
rm -fr mac-onboard

