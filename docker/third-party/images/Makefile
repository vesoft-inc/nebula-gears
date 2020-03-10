tags=centos-6 centos-7 ubuntu-1604 ubuntu-1804

all: $(tags)

build-%: %.Dockerfile
	@echo '******************' Build image $* '********************'
	@docker build -t dutor/third-party-build:$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $* '********************'
	@docker push dutor/third-party-build:$*

%: push-% ;
