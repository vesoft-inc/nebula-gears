tags=centos-6 centos-7 ubuntu-1604 ubuntu-1804

all: $(tags)

%:
	@echo '******************' Build image $* '********************'
	@docker run --env-file=$$HOME/.oss_env --rm -it dutor/third-party-build:$* ./build-third-party.sh
