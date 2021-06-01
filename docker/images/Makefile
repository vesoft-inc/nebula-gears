arch=$(shell uname -m)
tags=centos-7

all: $(tags)

.PHONY: all

build-%: $(arch)/%.Dockerfile
	@echo '******************' Build Image $* '********************'
	@docker build --no-cache -t vesoft-inc/toolset-build:$*-$(arch) -f $(arch)/$*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing Image $* '********************'
	@docker push vesoft-inc/toolset-build:$*-$(arch)

%: push-% ;
