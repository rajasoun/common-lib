APP := $(shell basename $(CURDIR))
VERSION := $(shell git describe --tags --always --dirty)
GOPATH := $(CURDIR)/Godeps/_workspace:$(GOPATH)
PATH := $(GOPATH)/bin:$(PATH)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
#.PHONY: bin/$(APP) bin clean start test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Go TASKS
go:  bin/$(APP) bin go_clean go_test ## Build Go

bin/$(APP): bin
	go build -v -o $@ -ldflags "-X main.Version='${VERSION}'"

bin: go_clean
	mkdir -p bin 

go_tdd:  ## TDD Go
	gotestsum --watch --format testname

go_test:  ## Test Go
	go test -v ./... --cover

go_clean: ## Clean Go
	rm -rf bin 

go_build:  bin/$(APP) bin go_clean 
	
