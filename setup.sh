#!/bin/bash

GPG_DIR="$HOME/.gnupg/"

[ ! -d "$GPG_DIR" ] && mkdir -p "$GPG_DIR"
echo "Copying gpg.conf file"
cp .gnupg/gpg.conf $GPG_DIR

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*)
    machine=Linux
    echo "We are on ${machine}."
    ;;

Darwin*)
    machine=Mac
    echo "We are on ${machine}."
    brew install pinentry-mac gpgme gpg
    echo "All tools for GPG should already be installed. If not..."
    echo "Copying gpg-agent.conf file"
    cp .gnupg/gpg-agent.conf $GPG_DIR
    echo "Killing gpg-agent"
    killall gpg-agent
    ;;
CYGWIN*)
    machine=Cygwin
    echo "${machine} is not supported"
    ;;
MINGW*)
    machine=MinGw
    echo "${machine} is not supported"
    ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac
