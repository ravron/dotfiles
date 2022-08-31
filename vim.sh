#!/usr/bin/env bash

set -eu

readonly vim_version=$(vim --version | head -1 | cut -d ' ' -f 5)
readonly min_vim_version="8.0"

if [[ $(bc <<<"$vim_version >= $min_vim_version") == "0" ]]; then
    cat >&2 <<DONE
vim at:
    $(command -v vim)
is version $vim_version, but native vim packages require vim $min_vim_version or
above. You can:
  - Cancel and run brew.sh first to install the latest version of vim
  - Proceed, which will install the packages where vim >= $min_vim_version would
    look for them. They will not be used until you install a sufficiently new
    version of vim.
DONE
    read -p "Proceed with installation of packages? (y/N) " -n 1;
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    echo ""
fi



# I don't believe $USER can have spaces, but no harm in quoting it anyways.
#readonly pack_path=~/.vim/pack/"${USER}"/start
readonly pack_path=~/.local/share/nvim/site/pack/"${USER}"/start
echo "Installing vim packages to ${pack_path}..."

mkdir -p "$pack_path"
cd "$pack_path"

function package () {
    local -r repo_url="$1"
    local -r expected_repo=$(basename "$repo_url" .git)
    if [ -d "$expected_repo" ]; then
        (
        cd "$expected_repo"
        local -r result=$(git -c 'color.ui=always' pull)
        echo "$expected_repo: $result"
        )
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
package git@github.com:morhetz/gruvbox.git
package git@github.com:leafgarland/typescript-vim.git
package git@github.com:cespare/vim-toml.git
package git@github.com:junegunn/fzf.git
package git@github.com:junegunn/fzf.vim.git

# Wait for all outstanding jobs to terminate. Only necessary if running jobs in
# background.
# wait
