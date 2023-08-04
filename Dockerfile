FROM debian
RUN apt-get update --yes && \
    apt-get install --yes \
            bash-completion \
            build-essential \
            curl \
            git \
            libgccjit-12-dev \
            libgif-dev \
            libgmp-dev \
            libgnutls28-dev \
            libgtk-3-dev \
            libjansson-dev \
            libjpeg-dev \
            libpng-dev \
            libtiff-dev \
            libtinfo-dev \
            libtree-sitter-dev \
            libxpm-dev \
            rsync \
            unzip
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
               signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
          https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt-get update --yes && apt-get install --yes gh
RUN curl --remote-name https://ftp.gnu.org/gnu/emacs/emacs-29.1.tar.xz
RUN tar -xf emacs-29.1.tar.xz
WORKDIR /emacs-29.1
RUN ./configure --with-native-compilation
RUN make
RUN make install
RUN curl -fsSL --remote-name \
    https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh
RUN sh ./install.sh <<EOF
/usr/local/bin
EOF
RUN adduser ilankri
USER ilankri
RUN opam init --auto-setup --disable-sandboxing --yes
RUN opam update --yes && opam install --yes ocaml-lsp-server
WORKDIR /home/ilankri
COPY --chown=ilankri . .
RUN opam pin add --kind=path --yes .config/emacs/
RUN make
CMD ["bash", "--login"]
