SHELL = /bin/sh
DUNE = opam exec -- dune

.SUFFIXES:
.PHONY: all build clean

all: build

build:
	$(DUNE) build my/my.so

clean:
	$(DUNE) clean
