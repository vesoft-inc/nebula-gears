arch=$(shell uname -m)
tags=centos-7 debian-9

all: $(tags)
print:
	@echo $(tags)

.PHONY: all
.PHONY: print

oss_endpoint := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^endpoint=(.*);\1;p' -rn $$HOME/.ossutilconfig)
oss_id := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^accessKeyID=(.*);\1;p' -rn $$HOME/.ossutilconfig)
oss_secret := $(shell [[ -f $$HOME/.ossutilconfig ]] && sed 's;^accessKeySecret=(.*);\1;p' -rn $$HOME/.ossutilconfig)

docker_cmd := docker run -v $$PWD/toolset-packages:/data
ifneq ($(oss_endpoint),)
	docker_cmd += -e OSS_ENDPOINT=$(oss_endpoint) -e OSS_ID=$(oss_id) -e OSS_SECRET=$(oss_secret)
endif
ifneq ($(BUILD_GCC_VERSIONS),)
	docker_cmd += -e BUILD_GCC_VERSIONS=$(BUILD_GCC_VERSIONS)
endif
ifneq ($(BUILD_LLVM_VERSIONS),)
	docker_cmd += -e BUILD_LLVM_VERSIONS=$(BUILD_LLVM_VERSIONS)
endif

%: gcc-% llvm-% ;

gcc-%:
	@echo '******************' Build Nebula Toolset/GCC For $*-$(arch) '********************'
	@$(docker_cmd) --rm -it vesoft/toolset-build:$*-$(arch) ./build-gcc.sh

llvm-%:
	@echo '******************' Build Nebula Toolset/LLVM For $*-$(arch) '********************'
	@$(docker_cmd) --rm -it vesoft/toolset-build:$*-$(arch) ./build-llvm.sh
