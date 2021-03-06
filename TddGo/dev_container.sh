#!/usr/bin/env bash

BASE_URL="https://raw.githubusercontent.com/rajasoun/ci-shell-iaac/main/vscode-iaac"

function download_go_dev_container(){
    current_dir="$PWD"
    mkdir -p vscode-iaac/go
    GO_PATH="$BASE_URL/go"
    wget -q "$GO_PATH/go-goss.yaml"
    wget -q "https://raw.githubusercontent.com/rajasoun/common-lib/main/ci.sh" && chmod +x "ci.sh"
    wget -q "https://raw.githubusercontent.com/rajasoun/common-lib/main/TddGo/pre_checks.sh" && chmod +x "pre_checks.sh"
    mkdir -p .devcontainer &&  cd .devcontainer
    wget -q "$GO_PATH/.devcontainer/devcontainer.json"
    wget -q "$GO_PATH/.devcontainer/Dockerfile"
    cd $current_dir
}
