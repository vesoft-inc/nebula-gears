tags=centos-6 centos-7 debian-7 debian-8

all: $(tags)

%:
	@echo '******************' Build image $* '********************'
	@docker run --env-file=$$HOME/.oss_env --rm -it dutor/toolset-build:$* ./build-gcc.sh
