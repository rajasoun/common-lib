#!/usr/bin/env bash

BASE_URL="https://raw.githubusercontent.com/rajasoun/ci-shell-iaac/main/vscode-iaac"

function download_go_dev_container(){
    current_dir="$PWD"
    GO_PATH="$BASE_URL/go"
    wget "$GO_PATH/go-goss.yaml"
    wget "https://raw.githubusercontent.com/rajasoun/common-lib/main/ci.sh" && chmod +x "ci.sh"
    mkdir -p .devcontainer &&  cd .devcontainer
    wget "$GO_PATH/.devcontainer/devcontainer.json"
    wget "$GO_PATH/.devcontainer/Dockerfile"
    cd $current_dir
}