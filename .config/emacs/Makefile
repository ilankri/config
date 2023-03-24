SHELL = /bin/sh
DUNE = opam exec -- dune

.SUFFIXES:
.PHONY: all build clean

all: build

build:
	$(DUNE) build lib/init-packages/init_packages.so init.so

clean:
	$(DUNE) clean
