SHELL = /bin/sh
RM = rm -f

elispdir = ~/.emacs.d/lisp
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash install-emacs install-ocaml	\
	compile-emacs-lisp

all: install

install: install-bash install-emacs install-ocaml

clean:
	@echo "Cleaning..."
	@$(RM) $(elispdir)/*.elc
	@$(print_done)

install-bash:
	@$(print_installing) Bash
	@grep -q "if \[ -f ~/.mybashrc.bash ]; then" ~/.bashrc	\
	|| printf "\nif %s; then\n    %s\nfi\n"				\
		"[ -f ~/.mybashrc.bash ]"				\
		". ~/.mybashrc.bash"				\
		>> ~/.bashrc
	@$(print_done)

install-emacs: compile-emacs-lisp
	@$(print_installing) Emacs
	@emacs --batch --load $(elispdir)/my.el --funcall my-init-packages
	@$(print_done)

install-ocaml:
	@$(print_installing) OCaml
	@grep -q "#use \"$$HOME/.myocamlinit.ml\"" ~/.ocamlinit	\
	|| printf "\n#use \"$$HOME/.myocamlinit.ml\"\n"		\
		>> ~/.ocamlinit
	@$(print_done)

compile-emacs-lisp:
	@echo "Compiling Elisp files..."
	@emacs --batch --eval '(batch-byte-recompile-directory 0)' $(elispdir)
	@$(print_done)
