SHELL = /bin/sh
LN = ln -fs

srcdir = $(shell pwd)
bashdir = $(srcdir)/bash
bindir = $(srcdir)/bin
dockerdir = $(srcdir)/docker
emacsdir = $(srcdir)/emacs
elispdir = $(emacsdir)/lisp
gitdir = $(srcdir)/git
latexmkdir = $(srcdir)/latexmk
ocamldir = $(srcdir)/ocaml
ocpdir = $(srcdir)/ocp
readlinedir = $(srcdir)/readline
print_installing = printf "Installing %s config... "
print_done = echo "done."

.SUFFIXES:
.PHONY: all install clean install-bash install-bin install-docker	\
	install-emacs install-git install-latexmk install-ocaml		\
	install-ocp install-readline compile-emacs-lisp

all: install

install: install-bash install-bin install-docker install-emacs		\
		install-git install-latexmk install-ocaml install-ocp	\
		install-readline

clean:
	@$(RM) $(elispdir)/*.elc

install-bash:
	@$(print_installing) bash
	@$(LN) $(bashdir)/bashrc.bash ~/.bashrc
	@$(LN) $(bashdir)/bash_aliases.bash ~/.bash_aliases
	@$(print_done)

install-bin:
	@echo -n "Installing user's bin... "
	@$(LN) $(bindir) ~
	@$(print_done)

install-docker:
	@$(print_installing) docker
	@$(LN) $(dockerdir)/config.json ~/.docker
	@$(print_done)

install-emacs: compile-emacs-lisp
	@$(print_installing) emacs
	@$(LN) $(emacsdir)/gnus-init.el $(emacsdir)/signature		\
		$(emacsdir)/init.el $(emacsdir)/insert $(elispdir)	\
		~/.emacs.d
	@$(print_done)

install-git:
	@$(print_installing) git
	@$(LN) $(gitdir)/gitconfig ~/.gitconfig
	@$(LN) $(gitdir)/gitignore ~/.gitignore
	@$(print_done)

install-latexmk:
	@$(print_installing) latexmk
	@$(LN) $(latexmkdir)/latexmkrc.pl ~/.latexmkrc
	@$(print_done)

install-ocaml:
	@$(print_installing) ocaml
	@$(LN) $(ocamldir)/ocamlinit.ml ~/.ocamlinit
	@$(print_done)

install-ocp:
	@$(print_installing) ocp
	@$(LN) $(ocpdir)/ocp-indent.conf ~/.ocp
	@$(print_done)

install-readline:
	@$(print_installing) readline
	@$(LN) $(readlinedir)/inputrc ~/.inputrc
	@$(print_done)

compile-emacs-lisp:
	@echo "Compiling elisp files... "
	@emacs --batch --eval '(batch-byte-recompile-directory 0)'	\
		$(elispdir)
