arch=$(shell uname -m)
ifeq ($(arch), x86_64)
tags=$(addsuffix -$(arch), centos-6 centos-7 ubuntu-1604 ubuntu-1804 ubuntu-1910)
else
tags=$(addsuffix -$(arch), centos-7 ubuntu-1804)
endif

all: $(tags)

build-%: %.Dockerfile
	@echo '******************' Build image $* '********************'
	@docker build --no-cache -t dutor/third-party-build-$(arch):$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $* '********************'
	@docker push dutor/third-party-build-$(arch):$*

%: push-% ;
