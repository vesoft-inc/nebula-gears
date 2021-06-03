arch=$(shell uname -m)
tags=centos-7 debian-9

all: $(tags)
print:
	@echo $(tags)

.PHONY: all
.PHONY: print

build-%: $(arch)/%.Dockerfile
	@echo '******************' Build Image $*-$(arch) '********************'
	@docker build --no-cache -t vesoft/toolset-build:$*-$(arch) -f $(arch)/$*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing Image $*-$(arch) '********************'
	@docker push vesoft/toolset-build:$*-$(arch)

%: push-% ;
