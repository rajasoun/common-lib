# TDD with Go

## Dev Containers 

In terminal 

```
source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/TddGo/dev_container.sh)
download_go_dev_container
```

## Open Folder in Container within Visual Studio Code

In Visual Studio Code - Click the Green Button and Open in Dev Container`

## Pre-Requisites Check

In Terminal 

```
./pre_check.sh
```

It should give you result 💯  All Passed!

```
goss --gossfile go-goss.yaml validate
```

## Building Dev Containers Outsid of Visual Studio Code

In Terminal 

```
source <(curl -s https://raw.githubusercontent.com/rajasoun/common-lib/main/run_ci_shell.sh)
ln -s ${PWD}/.devcontainer vscode-iaac/go/.devcontainer
./ci.sh build -d
```

## Continously Run Go Tests

In Terminal 

```
gotestsum --watch --format testname
```
