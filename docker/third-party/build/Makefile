arch=$(shell uname -m)
ifeq ($(arch), x86_64)
tags=$(addsuffix -$(arch), centos-6 centos-7 ubuntu-1604 ubuntu-1804 ubuntu-1910 ubuntu-2010)
else
tags=$(addsuffix -$(arch), centos-7 ubuntu-1804)
endif

all: $(tags)

.PHONY: all

oss_endpoint := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^endpoint=(.*);\1;p' -rn $$HOME/.ossutilconfig)
oss_id := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^accessKeyID=(.*);\1;p' -rn $$HOME/.ossutilconfig)
oss_secret := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^accessKeySecret=(.*);\1;p' -rn $$HOME/.ossutilconfig)

docker_cmd := docker run -v $$PWD/third-party-packages:/data
ifneq ($(oss_endpoint),)
	docker_cmd += -e OSS_ENDPOINT=$(oss_endpoint) -e OSS_ID=$(oss_id) -e OSS_SECRET=$(oss_secret)
endif
ifneq ($(USE_GCC_VERSIONS),)
	docker_cmd += -e USE_GCC_VERSIONS=$(USE_GCC_VERSIONS)
endif

%:
	@echo '******************' Build Nebula Third Party For $* '********************'
	@$(docker_cmd) --rm -it dutor/third-party-build-$(arch):$* ./build-third-party.sh
