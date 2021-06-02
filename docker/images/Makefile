arch=$(shell uname -m)
tags=centos-7 debian-9

all: $(tags)

.PHONY: all

build-%: $(arch)/%.Dockerfile
	@echo '******************' Build Image $* '********************'
	@docker build --no-cache -t vesoft/toolset-build:$*-$(arch) -f $(arch)/$*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing Image $* '********************'
	@docker push vesoft/toolset-build:$*-$(arch)

%: push-% ;
