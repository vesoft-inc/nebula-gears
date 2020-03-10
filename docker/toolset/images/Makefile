tags=centos-6 centos-7 debian-7 debian-8

all: $(tags)

build-%: %.Dockerfile
	@echo '******************' Build image $* '********************'
	@docker build -t dutor/toolset-build:$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $* '********************'
	@docker push dutor/toolset-build:$*

%: push-% ;
