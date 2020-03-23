tags=centos-6 centos-7 centos-8 debian-7 debian-8 debian-9 debian-10

all: $(tags)

.PHONY: all

build-%: %.Dockerfile
	@echo '******************' Build Image $* '********************'
	@docker build --no-cache -t dutor/toolset-build:$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing Image $* '********************'
	@docker push dutor/toolset-build:$*

%: push-% ;
