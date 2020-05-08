SHELL = /bin/sh
RM = rm -f
LN = ln -fs
MKDIR = mkdir -p
CP = cp -r

srcdir = $(shell pwd)
bashdir = $(srcdir)/bash
bindir = $(srcdir)/bin
dockerdir = $(srcdir)/docker
dockerinstalldir = ~/.docker
emacsdir = $(srcdir)/emacs
elispdir = $(emacsdir)/lisp
gitdir = $(srcdir)/git
ocamldir = $(srcdir)/ocaml
ocpdir = $(srcdir)/ocp
ocpinstalldir = ~/.ocp
readlinedir = $(srcdir)/readline
x11dir = $(srcdir)/X11
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash install-bin install-docker	\
	install-emacs install-git install-ocaml install-ocp		\
	install-readline install-x11 compile-emacs-lisp

all: install

install: install-bash install-bin install-docker install-emacs		\
		install-git install-ocaml install-ocp install-readline	\
		install-x11

clean:
	@echo "Cleaning..."
	@$(RM) $(elispdir)/*.elc
	@$(print_done)

install-bash:
	@$(print_installing) Bash
	@grep -q "if \[ -f $(bashdir)/bashrc.bash ]; then" ~/.bashrc	\
	|| printf "\nif %s; then\n    %s\nfi\n"				\
		"[ -f $(bashdir)/bashrc.bash ]"				\
		". $(bashdir)/bashrc.bash"				\
		>> ~/.bashrc
	@$(LN) $(bashdir)/bash_aliases.bash ~/.bash_aliases
	@$(print_done)

install-bin:
	@echo "Installing user's bin..."
	@$(LN) $(bindir) ~
	@$(print_done)

install-docker:
	@$(print_installing) Docker
	@$(MKDIR) $(dockerinstalldir)
	@$(LN) $(dockerdir)/config.json $(dockerinstalldir)
	@$(print_done)

install-emacs: compile-emacs-lisp
	@$(print_installing) Emacs
	@emacs --batch --load $(elispdir)/my.el --funcall my-init-packages
	@$(LN) $(emacsdir)/init.el ~/.emacs
	@$(LN) $(emacsdir)/insert $(elispdir) ~/.emacs.d
	@$(print_done)

install-git:
	@$(print_installing) Git
	@$(LN) $(gitdir)/gitconfig ~/.gitconfig
	@$(LN) $(gitdir)/gitignore ~/.gitignore
	@$(print_done)

install-ocaml:
	@$(print_installing) OCaml
	@grep -q "#use \"$(ocamldir)/ocamlinit.ml\"" ~/.ocamlinit	\
	|| printf "\n#use \"$(ocamldir)/ocamlinit.ml\"\n"		\
		>> ~/.ocamlinit
	@$(print_done)

install-ocp:
	@$(print_installing) OCP
	@$(MKDIR) $(ocpinstalldir)
	@$(LN) $(ocpdir)/ocp-indent.conf $(ocpinstalldir)
	@$(print_done)

install-readline:
	@$(print_installing) Readline
	@$(LN) $(readlinedir)/inputrc ~/.inputrc
	@$(print_done)

install-x11:
	@$(print_installing) X11
	@$(LN) $(x11dir)/xsessionrc ~/.xsessionrc
	@$(LN) $(x11dir)/Xresources ~/.Xresources
	@$(print_done)

compile-emacs-lisp:
	@echo "Compiling Elisp files..."
	@emacs --batch --eval '(batch-byte-recompile-directory 0)' $(elispdir)
	@$(print_done)
