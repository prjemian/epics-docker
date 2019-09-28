# build all subdirectories
# https://stackoverflow.com/questions/17834582/run-make-in-each-subdirectory

TOPTARGETS := build push

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
