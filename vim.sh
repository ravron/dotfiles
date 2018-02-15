#!/usr/bin/env bash

set -eu

# I don't believe $USER can have spaces, but no harm in quoting it anyways.
readonly pack_path=~/.vim/pack/"${USER}"/start
echo $pack_path

mkdir -p "$pack_path"
cd "$pack_path"

# Note that this function changes the working directory.
function package () {
    local -r repo_url="$1"
    local -r expected_repo=$(basename "$repo_url" .git)
    if [ -d "$expected_repo" ]; then
        cd "$expected_repo"
        local -r result=$(git pull)
        echo "$expected_repo: $result"
    else
        echo "$expected_repo: Installing..."
        git clone --quiet "$repo_url"
    fi
}

# Auth to github, making sure the agent has keys so that we don't need to
# interact with the clone commands. Successful auth exits 1 anyways; OR with
# true to prevent exit due to set -e.
ssh -T git@github.com &>/dev/null || true

# Right now there are only a couple of packages, so just do them serially. If
# too many are accumulated, each can be started as a background job.

package git@github.com:airblade/vim-gitgutter.git
package git@github.com:altercation/vim-colors-solarized.git

# Wait for all outstanding jobs to terminate. Only necessary if running jobs in
# background.
# wait
