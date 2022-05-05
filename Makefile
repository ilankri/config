SHELL = /bin/sh
RM = rm -f
DOCKER_IMAGE_TAG = ilankri-dotfiles

elispdir = ~/.config/emacs/lisp
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash install-emacs install-ocaml	\
	compile-emacs-lisp docker-build docker-debug-emacs-init

all: install

install: install-bash install-emacs install-ocaml

clean:
	@echo "Cleaning..."
	@$(RM) $(elispdir)/*.elc
	@$(print_done)

install-bash:
	@$(print_installing) Bash
	@grep -q "if \[ -f ~/.mybashrc.bash ]; then" ~/.bashrc	\
	|| printf "\nif %s; then\n    %s\nfi\n"			\
		"[ -f ~/.mybashrc.bash ]"			\
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

docker-build:
	docker build --tag $(DOCKER_IMAGE_TAG) .


docker-debug-emacs-init: docker-build
	docker run --interactive --rm --tty $(DOCKER_IMAGE_TAG)	\
		bash -icl "emacs --debug-init"
