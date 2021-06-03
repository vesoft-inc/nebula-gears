arch=$(shell uname -m)
ifeq ($(arch),aarch64)
	tags=centos-7 debian-9
else
	tags=centos-7 debian-8
endif

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
