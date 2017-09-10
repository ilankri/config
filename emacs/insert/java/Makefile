SHELL = /bin/sh
JAVAC = javac
JAVACFLAGS = -g -Xlint
JAVA = java

SRCS =
CLS = $(SRCS:.java=.class)
EXEC =

compile = $(JAVAC) $(JAVACFLAGS)

.SUFFIXES:
.SUFFIXES: .class .java
.PHONY: all clean

all: $(CLS)

%.class: %.java
	$(compile) $<

clean:
	$(RM) $(CLS)
