SHELL = /bin/sh
DOCKER_IMAGE_TAG = ilankri-dotfiles

econfdir = ~/.config/emacs
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash compile-emacs-config \
	docker-build docker-debug-emacs-init

all: compile-emacs-config install

install: install-bash

clean:
	@echo "Cleaning..."
	@$(MAKE) -C $(econfdir) clean
	@$(print_done)

install-bash:
	@$(print_installing) Bash
	@grep -q "if \[ -f ~/.config/bash/bashrc.bash ]; then"	\
		~/.bashrc					\
	|| printf "\nif %s; then\n    %s\nfi\n"			\
		"[ -f ~/.config/bash/bashrc.bash ]"		\
		". ~/.config/bash/bashrc.bash"			\
		>> ~/.bashrc
	@$(print_done)

compile-emacs-config:
	@echo "Compiling Emacs config..."
	@$(MAKE) -C $(econfdir) build
	@$(print_done)

docker-build:
	docker build --tag $(DOCKER_IMAGE_TAG) .

docker-debug-emacs-init: docker-build
	docker run --interactive --rm --tty $(DOCKER_IMAGE_TAG)	\
		bash -icl "emacs --debug-init"
