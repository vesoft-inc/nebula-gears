tags=centos-6 centos-7 debian-7 debian-8

all: $(tags)

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

%:
	@echo '******************' Build Nebula Toolset For $* '********************'
	@$(docker_cmd) --rm -it dutor/toolset-build:$* ./build-gcc.sh
