#!/usr/bin/env bash

set -euo pipefail

print_help() {
    cat <<EOF
Create symlinks in your home directory that point to files in this repository.
    -n    dry-run: show what would be done
    -h    help: show this help and exit
EOF
}

die() {
    >&2 echo "fatal: $1"
    exit 1
}

find_paths() {
    # see comment about karabiner below
    find \
        . \
        \! \( -name ".git" -type d -prune \) \
        \! \( -name "init" -type d -prune \) \
        \! \( -name "karabiner" -type d -prune \) \
        \! -name "." \
        \! -name ".DS_Store" \
        \! -name "bootstrap.sh" \
        \! -name "brew.sh" \
        \! -name "find_bootstrap.sh" \
        \! -name "macos.sh" \
        \! -name "vim.sh" \
        \! -name "README.md" \
        \! -name "*.swp" \
        -type "$1" \
        -print0
}

check_file() {
    local -r DEST_FILE="$HOME/$1"
    # if file exists
    if [[ -e "$DEST_FILE" ]]; then
        # if the file is a symlnk and the symlink's target is exactly $DEST_FILE
        if [[ -h "$DEST_FILE" && 
            $(readlink "$DEST_FILE") == "$PWD/$1" ]]; then
            # then it's already correct and doesn't need linking
            return 0
        fi
        # else it exists and is incorrect! don't overwrite
        return 1
    fi
    # else it doesn't exist
    return 0
}

process_dir() {
    local -r DEST_DIR="$HOME/$1"
    if [[ -d "$DEST_DIR" ]]; then
        # already exists
        return
    fi

    if [[ $DRY_RUN ]]; then
        echo "would mkdir $DEST_DIR"
        return
    fi

    echo "making dir $DEST_DIR"
    mkdir -p "$DEST_DIR"
}

process_file() {
    local -r DEST_FILE="$HOME/$1"
    # if the file is a symlnk and the symlink's target is exactly $DEST_FILE
    if [[ -e "$DEST_FILE" ]]; then
        if [[ -h "$DEST_FILE" && 
            $(readlink "$DEST_FILE") == "$PWD/$1" ]]; then
            # then it's already correct and doesn't need linking
            return
        fi
        
        # else it exists and isn't a symlink or doesn't point to the right place
        # already. this should have been caught in check_file, but never hurts
        # to be paranoid.
        die "unexpected file exists after check_file"
    fi

    if [[ $DRY_RUN ]]; then
        echo "would link $DEST_FILE -> $PWD/$1"
        return
    fi

    echo "linking $DEST_FILE -> $PWD/$1"
    ln -s "$PWD/$1" "$DEST_FILE"
}

cd "$(dirname "${BASH_SOURCE}")"

DRY_RUN=
FORCE=

while getopts ':nh' OPT; do
    case "$OPT" in
        n)
            DRY_RUN=1
            ;;
        h)
            print_help
            exit 0
            ;;
        \?)  # without \, would match any single character
            print_help
            die "illegal option $OPTARG"
            ;;
    esac
done

DIRS_ARR=()
TO_LINK_ARR=()

# read null-delimited directory names from find -print0 into DIRS_ARR
while IFS= read -r -d '' DIR; do
    # remove leading './'
    DIR=$(cut -c 3- <<<"$DIR")
    DIRS_ARR+=("$DIR")
done < <(find_paths d)

while IFS= read -r -d '' FILE; do
    FILE=$(cut -c 3- <<<"$FILE")
    TO_LINK_ARR+=("$FILE")
done < <(find_paths f)

# karabiner overwrites its configuration file, and so its directory must be
# symlinked instead. sigh.
# https://github.com/tekezo/Karabiner-Elements/issues/1284
TO_LINK_ARR+=(".config/karabiner")

CHECK_RESULT=
for FILE in "${TO_LINK_ARR[@]}"; do
    if ! check_file "$FILE"; then
        CHECK_RESULT=1
        echo "file already exists: $HOME/$FILE"
    fi
done

if [[ $CHECK_RESULT ]]; then
    if [[ $DRY_RUN ]]; then
        echo "would refuse to overwrite one or more files"
        exit 0
    fi
    die "refusing to overwrite one or more files"
fi

for DIR in "${DIRS_ARR[@]}"; do
    process_dir "$DIR"
done

for FILE in "${TO_LINK_ARR[@]}"; do
    process_file "$FILE"
done
