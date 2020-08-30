SHELL = /bin/sh
RM = rm -f
JAVAC = javac
JAVACFLAGS = -g -Xlint

MAIN_SRC =
MAIN_CLASS = $(MAIN_SRC:.java=.class)
SRCS =
CLASSES = $(SRCS:.java=.class)

compile = $(JAVAC) $(JAVACFLAGS)

.SUFFIXES:
.SUFFIXES: .class .java
.PHONY: all clean

all: $(MAIN_CLASS)

$(MAIN_CLASS): $(MAIN_SRC) $(CLASSES)
	$(compile) $<

%.class: %.java
	$(compile) $<

clean:
	$(RM) $(MAIN_CLASS) $(CLASSES)
