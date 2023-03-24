SHELL = /bin/sh
DOCKER_IMAGE_TAG = ilankri-dotfiles

elibdir = ~/.config/emacs/lib
print_installing = printf "Installing %s config...\n"
print_done = echo "Done"

.SUFFIXES:
.PHONY: all install clean install-bash install-emacs compile-emacs-lib	\
	docker-build docker-debug-emacs-init

all: install

install: install-bash install-emacs

clean:
	@echo "Cleaning..."
	@$(MAKE) -C $(elibdir) clean
	@$(print_done)

install-bash:
	@$(print_installing) Bash
	@grep -q "if \[ -f ~/.mybashrc.bash ]; then" ~/.bashrc	\
	|| printf "\nif %s; then\n    %s\nfi\n"			\
		"[ -f ~/.mybashrc.bash ]"			\
		". ~/.mybashrc.bash"				\
		>> ~/.bashrc
	@$(print_done)

install-emacs: compile-emacs-lib
	@$(print_installing) Emacs
	@emacs --batch --directory $(elibdir)				\
		--load $(elibdir)/my/my.so --funcall my-init-packages
	@$(print_done)

compile-emacs-lib:
	@echo "Compiling Emacs library files..."
	@$(MAKE) -C $(elibdir) build
	@$(print_done)

docker-build:
	docker build --tag $(DOCKER_IMAGE_TAG) .


docker-debug-emacs-init: docker-build
	docker run --interactive --rm --tty $(DOCKER_IMAGE_TAG)	\
		bash -icl "emacs --debug-init"
