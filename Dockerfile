FROM debian
RUN apt-get update --yes && \
    apt-get install --yes \
	    bash-completion \
	    curl \
	    emacs \
	    git \
	    opam
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
	       signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
	  https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt-get update --yes && apt-get install --yes gh
RUN adduser ilankri
USER ilankri
RUN opam init --auto-setup --disable-sandboxing --yes
RUN opam update --yes && opam install --yes ocaml-lsp-server
WORKDIR /home/ilankri
COPY --chown=ilankri . .
RUN make
CMD ["bash"]
