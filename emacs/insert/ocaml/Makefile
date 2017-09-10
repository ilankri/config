SHELL = /bin/sh
OCAMLBUILD = ocamlbuild
DEBUGFLAG = -g
OCAMLCFLAGS = -cflags $(DEBUGFLAG),-annot,-bin-annot,-w,A
OCAMLLFLAGS = -lflags $(DEBUGFLAG)
OCAMLLIBS =

TARGET =

build = $(OCAMLBUILD) $(OCAMLCFLAGS) $(OCAMLLFLAGS) $(OCAMLLIBS)
clean = $(OCAMLBUILD) -clean

.SUFFIXES:
.PHONY: all $(TARGET) clean

all: $(TARGET)

$(TARGET):
	$(build) $@

clean:
	$(clean)
