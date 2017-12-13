#!/usr/bin/env bash

set -eux

mkdir -p ~/.vim/pack/ravron/start

function package () {
    local repo_url=$1
    local expected_repo=$(basename "$repo_url" .git)
    if [ -d "$expected_repo" ]; then
        cd "$expected_repo"
        local result=$(git pull)
        echo "$expected_repo: $result"
    else
        echo "$expected_repo: Installing..."
        git clone -q "$repo_url"
    fi
}

package git@github.com:airblade/vim-gitgutter.git
