SHELL = /bin/sh
RM = rm -f
PDFLATEX = pdflatex
PDFLATEXFLAGS = -interaction nonstopmode -file-line-error

TARGET =
SRCS = $(TARGET:.pdf=.tex)

compile = $(PDFLATEX) $(PDFLATEXFLAGS)

.PHONY: all mostlyclean clean

all: $(TARGET)

$(TARGET): $(SRCS)
	$(compile) $<
	$(compile) $<

mostlyclean:
	$(RM) $(SRCS:.tex=.log) $(SRCS:.tex=.aux)

clean: mostlyclean
	$(RM) $(TARGET)
