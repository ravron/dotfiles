#!/usr/bin/env bash

set -eu

readonly pack_path=~/.vim/pack/ravron/start

mkdir -p "$pack_path"
cd "$pack_path"

# Note that this function changes the working directory.
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

# Auth to github, making sure the agent has keys so that we don't need to interact with the clone commands. Successful
# auth exits 1 anyways; OR with true to prevent exit due to set -e.
ssh -T git@github.com &>/dev/null || true

package git@github.com:airblade/vim-gitgutter.git &
package git@github.com:altercation/vim-colors-solarized.git &

wait
