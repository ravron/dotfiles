#!/usr/bin/env bash

set -eu

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
    rsync --exclude "/.git/" \
        --exclude ".DS_Store" \
        --exclude "/bootstrap.sh" \
        --exclude "/brew.sh" \
        --exclude "/macos.sh" \
        --exclude "/vim.sh" \
        --exclude "/init/" \
        --exclude "/README.md" \
        --checksum \
        --archive \
        --verbose \
        --human-readable \
        --no-perms . ~;
    set +x
    source ~/.bash_profile;
    set -x
}

if [ "${1-}" == "--force" -o "${1-}" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;
