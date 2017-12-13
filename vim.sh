#!/usr/bin/env bash

set -eux

readonly pack_path=~/.vim/pack/ravron/start

mkdir -p "$pack_path"
cd "$pack_path"

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

package git@github.com:airblade/vim-gitgutter.git &
package git@github.com:altercation/vim-colors-solarized.git &

wait
