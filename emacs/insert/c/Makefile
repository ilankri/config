SHELL = /bin/sh
CC = gcc
CPPFLAGS = -MD -MP
DEBUGFLAG = -g3
CFLAGS = $(DEBUGFLAG) -pedantic-errors -Wall -Wextra -Wconversion -Wfloat-equal
LDFLAGS = $(DEBUGFLAG)
LDLIBS =

SRCS =
OBJS = $(SRCS:.c=.o)
DEPS = $(SRCS:.c=.d)
EXEC =

compile = $(CC) -c $(CPPFLAGS) $(CFLAGS)
link = $(CC) $(LDFLAGS)

.SUFFIXES:
.SUFFIXES: .o .c
.PHONY: all clean

all: $(EXEC)

$(EXEC): $(OBJS)
	$(link) $^ $(LDLIBS) -o $@

%.o: %.c
	$(compile) $<

-include $(DEPS)

clean:
	$(RM) $(OBJS) $(DEPS) $(EXEC)
