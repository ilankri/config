export LANG=en_US.UTF-8

export GNUPGHOME=~/.config/gnupg
export GPG_TTY=$(tty)

export OCAMLPARAM="_,bin-annot=1"
# See
# https://github.com/ocaml/merlin/wiki/Letting-merlin-locate-go-to-stuff-in-.opam.

## OPAM configuration
export OPAMJOBS=$(nproc)
export OPAMDOWNLOADJOBS=$(nproc)
export OPAMKEEPBUILDDIR=true
export OPAMWITHDOC=true
export PATH=$PATH:$(opam var --switch=default bin)

## Git prompt

# Username and host in green and working directory in blue.
my_ps1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]"

# Inspired by
# http://git.savannah.gnu.org/cgit/bash.git/plain/examples/functions/exitstat.
function prompt_end() {
    local status="$?"
    local signal=""

    if [ ${status} -ne 0 ] && [ ${status} != 128 ]; then
        # If process exited by a signal, determine name of signal.
        if [ ${status} -gt 128 ]; then
            signal="$(builtin kill -l $((${status} - 128)) 2>/dev/null)"
            if [ "$signal" ]; then signal=" ($signal)"; fi
        fi
        echo "\[\033[31m\]\\\$[${status}${signal}]\[\033[00m\]"
    else
        echo "\\\$"
    fi
}

function odig_env_hook() {
    local status="$?"

    export ODIG_CACHE_DIR=$(opam var prefix)/var/cache/odig
    export ODIG_DOC_DIR=$(opam var doc)
    export ODIG_LIB_DIR=$(opam var lib)
    return $status
}

export PROMPT_COMMAND='odig_env_hook; __git_ps1 $my_ps1 "$(prompt_end) "'
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM='verbose name'
export GIT_PS1_DESCRIBE_STYLE=default
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_HIDE_IF_PWD_IGNORED=1

## Miscellaneous settings

# To avoid errors.
set -o noclobber
shopt -s checkjobs

# Extend pattern matching features.
shopt -s extglob

export GOPATH=~/go
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin:~/bin:$GOPATH/bin
export INPUTRC=~/.config/readline/inputrc
export RLWRAP_HOME=~/.rlwrap
export EDITOR=emacsclient
export ALTERNATE_EDITOR=emacs
export ESHELL=my-eshell
export BROWSER=firefox
export PAGER=less
export EMAIL=ilankri@protonmail.com
export OCAMLRUNPARAM=b

# npm
export PATH=$PATH:~/.npm-global/bin

# GitHub CLI
eval "$(gh completion -s bash)"

# sbt
export SBT_NATIVE_CLIENT=true

# Docker
export DOCKER_CONFIG=~/.config/docker

## Aliases
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias lh='ls -h'
alias ll='lh -l'
alias la='ll -A'
alias df='df -h'
alias du='du -h'
alias up='sudo apt update && sudo apt upgrade'
alias opamup='opam update -u'
alias mr-sync='mr -j $(nproc) -d ~ -c ~/.mrconfig fetch'
alias clear-swap='sudo swapoff -a && sudo swapon -a'
alias docker-killall='docker rm -f $(docker ps -aq)'

## SSH initialization
. my-ssh-init
