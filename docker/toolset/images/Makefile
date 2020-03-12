tags=centos-6 centos-7 debian-7 debian-8

all: $(tags)

build-%: %.Dockerfile
	@echo '******************' Build Image $* '********************'
	@docker build --no-cache -t dutor/toolset-build:$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing Image $* '********************'
	@docker push dutor/toolset-build:$*

%: push-% ;
