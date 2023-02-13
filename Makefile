SHELL = /bin/sh
DOCKER_IMAGE_TAG = ilankri-dotfiles

elispdir = ~/.config/emacs/lisp
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash install-emacs compile-emacs-lisp	\
	docker-build docker-debug-emacs-init

all: install

install: install-bash install-emacs

clean:
	@echo "Cleaning..."
	@$(MAKE) -C $(elispdir) clean
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
	@emacs --batch --directory $(elispdir) --load $(elispdir)/my.so	\
		--funcall my-init-packages
	@$(print_done)

compile-emacs-lisp:
	@echo "Compiling Elisp files..."
	@$(MAKE) -C $(elispdir) build
	@$(print_done)

docker-build:
	docker build --tag $(DOCKER_IMAGE_TAG) .


docker-debug-emacs-init: docker-build
	docker run --interactive --rm --tty $(DOCKER_IMAGE_TAG)	\
		bash -icl "emacs --debug-init"
