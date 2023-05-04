.PHONY:
help:
	echo "See README.md"

ifeq ($(V),)
.SILENT:
endif

MAKEFLAGS += --no-builtin-rules --no-builtin-variables
.SUFFIXES:

PROGRESS := printf "  \\033[1;96m%10s\\033[0m  \\033[1;m%s\\033[0m\\n"

GIT_TAG ?= digital-ocean-support

os:
	$(MAKE) app
	$(MAKE) unikernel
	$(MAKE) -C build/unikernel IMAGE=deploy-app RELEASE=1
	mkdir -p image
	cp build/unikernel/unikernel.x64.elf image/unikernel.elf

re-build:
	$(MAKE) app
	rm -rf build/unikernel/build
	rm build/unikernel/unikernel.*
	$(MAKE) -C build/unikernel IMAGE=deploy-app RELEASE=1
	cp build/unikernel/unikernel.x64.elf image/unikernel.elf

run:
	$(PROGRESS) Running App 
	$(MAKE) -C build/unikernel IMAGE=deploy-app RELEASE=1 run

unikernel:
	$(PROGRESS) Downloading $@
	mkdir -p build
	git clone https://github.com/Dhanush-arch/uni-kernel build/unikernel
	cd build/unikernel && git checkout $(GIT_TAG)

app:
	$(PROGRESS) Building Deploy-app
	docker buildx build -t deploy-app .

.PHONY: optimize-images
optimize-images:
	$(PROGRESS) "OPTIMIZE"
	echo blog/media/*.jpg | xargs -I '{}' -n 1 -P $(shell nproc) bash -c "jpegtran -copy none -optimize -progressive -outfile {}.tmp {}; mv {}.tmp {}"
	echo blog/media/*.png | xargs -I '{}' -n 1 -P $(shell nproc) bash -c "optipng -out {}.tmp {}; mv {}.tmp {}"
