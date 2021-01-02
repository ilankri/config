FROM ubuntu
RUN apt-get update --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
					   bash-completion \
					   emacs \
					   git \
					   gnupg \
					   locales \
					   opam \
					   software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
RUN apt-add-repository https://cli.github.com/packages
RUN apt-get update --yes && apt-get install --yes gh
RUN locale-gen en_US.UTF-8
RUN adduser ilankri
USER ilankri
RUN opam init --auto-setup --disable-sandboxing --yes
RUN opam update --yes && \
    opam install --yes caml-mode ocaml-lsp-server ocamlformat ocp-indent tuareg
WORKDIR /home/ilankri
COPY --chown=ilankri . .
RUN make
CMD ["bash"]
