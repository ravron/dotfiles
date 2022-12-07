# Lines configured by zsh-newuser-install
setopt nolistbeep beep nomatch extendedglob
unsetopt autocd notify
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/ravron/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Get private configuration
[[ -f ~/.zshrc_private ]] && source ~/.zshrc_private

# Make `run-help` work. 
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Accessing-On_002dLine-Help
alias run-help &>/dev/null && unalias run-help
autoload -Uz run-help
alias help='run-help'

## Get useful modules
autoload -Uz add-zsh-hook

## Configure prompt
# Configure vcs_info
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
# and https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
autoload -Uz vcs_info
# Don't even attempt to use any backends except git
# Check vcs_info_printsys to see what's enabled
zstyle ':vcs_info:*' enable git
# When git is detected, use this format. %b is branch.
zstyle ':vcs_info:git:*' formats '(%b%c%u) '
# If we're in the middle of an action, like rebase, use this instead
# %a tells us what action we're doing, and %m will be replaced by the
# patch-format format, configured on the following line
zstyle ':vcs_info:git:*' actionformats '(%b %a %m) '
# Replaces the %m directive in the actionformat format, configured on the
# previous line. %n is the number of unapplied patches, and %a is total number
# of patches.
zstyle ':vcs_info:git:*' patch-format '%n/%a'
# Check for a dirty worktree or index. Can be slow, if so disable on a per-repo
# basis
zstyle ':vcs_info:*' check-for-changes 'true'
# Show staged and unstaged work as a yellow ? or a red ! respectively. It's a
# bit fragile that these strings set color back to blue themselves.
zstyle ':vcs_info:*' stagedstr '%F{yellow}?%F{blue}'
zstyle ':vcs_info:*' unstagedstr '%F{red}!%F{blue}'
# When no VCS is detected, emit the empty string
zstyle ':vcs_info:*' nvcsformats ''
add-zsh-hook precmd vcs_info

# Add a hook for customizing the formatting of the git message. This hook is
# very simple: it uppercases the action name so that it stands out more, e.g.
# rebase-i to REBASE-I. It uses zsh parameter expansion flags, see
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
+vi-uppercase_action() {
    hook_com[action]=${(U)hook_com[action]}
}
zstyle ':vcs_info:git+set-message:*' hooks uppercase_action

# Allow substitutions in the prompt
setopt prompt_subst

# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
PROMPT=
# Set color to bright white
PROMPT+='%F{#FFFFFF}'
PROMPT+='■■▶ '
PROMPT+='%F{cyan}'
# Current working dir
PROMPT+='%1~ '
PROMPT+='%F{blue}'
PROMPT+='${vcs_info_msg_0_}'
 
PROMPT+='%F{magenta}'
# If currently using aws-vault profile, display it
PROMPT+='${AWS_VAULT+aws:${AWS_VAULT} }'

PROMPT+='%F{red}'
# If the previous exit code is false, then display it in brackets
PROMPT+='%(?..[%?] )'
# Print the SHLVL if it's at least 2
PROMPT+='%(2L.%L-.)'
PROMPT+='%(!.#.$)'
# Turn off colors
PROMPT+=' %f'

## Completion
zstyle ':completion:*' menu yes select search

## Key bindings
# Use vim bindings
bindkey -v
bindkey "^R" history-incremental-search-backward

## Misc zsh
# Turn off inverse on pasted text
zle_highlight=('paste:none')

## History
# See man zshoptions
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# histignoredups: don't store adjacent duplicate lines
# histverify: rather than just executing history expansion, expand and then
# redraw prompt
# incappendhistory: append to hist file after every command. won't pull history
# into shell session except at startup, so per-shell history stays coherent.
# histignorespace: don't save commands which start with a space
setopt histignoredups histverify incappendhistory histignorespace

## Command aliases
alias vi="nvim"
alias vim="nvim"
alias ll="ls -ahl"
alias g="git"
alias gp="gitpic"
alias date8601="date -u +'%Y-%m-%dT%H:%M:%SZ'"
# The second pattern in awk makes sure we don't touch the branch currently checked out
# (or try to git branch -D * !!)
# gdg for "git delete gone"
gdg() {
    git branch --delete --force \
        $(git branch --verbose | awk '/\[gone]/ && !/^\*/ {print $1}')
}
alias gpc="git push -u origin head && hub compare"

# hb takes one argument, a git ref, and browses to the PR's page, if possible,
# or else the commit's page. It identifies the PR's page by the commit message,
# looking for the last instance of a string like '(#1234)', to handle reverts. A
# future improvement would be to ask GH directly for the PR associated with a
# commit to avoid this heuristic, reliable though it usually is.
hb() {
    # Return immediately on non-zero exit, and restore options on return
    setopt errreturn localoptions
    commit=$(git rev-parse --verify $@)
    # git: get the commit message
    # rg: get strings that look like '(#1234)', one per line
    # tr: delete the parens and pound sign
    # tail: get the last line, in case of multiple matches
    PR=$(git show --no-patch --format=%B $commit | \
        rg --only-matching '(\(#\d+\))' | \
        tr -d '(#)' | \
        tail -1)

    if [[ -n $PR ]]; then
        hub browse -- "pull/$PR"
    else
        hub browse -- "commit/$commit"
    fi
}

# scd causes a connected gpg smartcard to prompt for a PIN, if locked.
scd() {
    # Return immediately on non-zero exit, and restore options on return
    setopt errreturn localoptions
    SERIAL=$(gpg-connect-agent 'scd serialno' /bye | \
        sed -n '1s/S SERIALNO //p')
    gpg-connect-agent "scd checkpin $SERIAL" /bye
}

aws-exec() {
    setopt errreturn localoptions
    OTP=$(op item get wfei6mkyxrord2mhai4qysrm6q --otp)
    aws-vault exec --mfa-token=$OTP "$@"
}


## External command configurations
# Makes ls color its output
export CLICOLOR=1
export LSCOLORS=gxFxCxDxbxexexaxaxaxex
# For `tree`. Convert from LSCOLORS above via https://geoff.greer.fm/lscolors/
export LS_COLORS='di=36:ln=1;35:so=1;32:pi=1;33:ex=31:bd=34:cd=34:su=30:sg=30:tw=30:ow=34'
# Would normally go in a previous section but makes most sense here
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Makes grep always color its output unless piped elsewhere
export GREP_OPTIONS='--color=auto'

# Lets gpg's pinentry ask for a PIN when needed
export GPG_TTY=$(tty)

# Make nvim the default editor
export EDITOR=nvim

LESS_ARR=(
# Case insensitive searching if search term doesn't contain an uppercase letter
'--ignore-case'
# Output ANSI color control characters directly. Useful to preserve color.
'--RAW-CONTROL-CHARS'
'--quit-if-one-screen'
)
export LESS=${LESS_ARR[@]}
# Set the control codes less emits for certain text attributes
# https://unix.stackexchange.com/a/108840/41650
# Convoluted way to get zsh to generate our cyan color for us. (%) tells it to
# do prompt expansion on the result. :- lets us provide a word directly with
# no variable. Must quote word to prevent closing brace being seen.
export LESS_TERMCAP_md="${(%):-"%F{yellow}"}"  # yellow for starting bold
export LESS_TERMCAP_us="${(%):-"%F{blue}"}"  # blue for starting underline
export LESS_TERMCAP_me="${(%):-"%f"}"  # reset for ending bold
export LESS_TERMCAP_ue="${(%):-"%f"}"  # reset for ending underline

# See brew info fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --type file --type symlink --exclude .git/objects'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --hidden --follow --type directory --exclude .git/objects'
# Use fd instead of find when triggered with **<tab>
# See /usr/local/opt/fzf/shell/completion.zsh
_fzf_compgen_path() {
    echo "$1"
    fd --hidden --follow --type directory --type file --type symlink --exclude .git/objects . "$1"
}
_fzf_compgen_dir() {
    fd --hidden --follow --type directory --exclude .git/objects . "$1"
}

# See man fasd
eval "$(fasd --init auto)"
alias v='f -e $EDITOR'

export RIPGREP_CONFIG_PATH=~/.config/rg/rg_config

export AWS_SDK_LOAD_CONFIG=1

## Add things to the PATH
# For an explanation of how this `path+=…` works, see
# http://zsh.sourceforge.net/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell

# Add diff-highlight executable to PATH. See
# https://github.com/git/git/tree/master/contrib/diff-highlight
if type brew > /dev/null; then
    path+="$(brew --prefix)/share/git-core/contrib/diff-highlight"
fi
# Ubuntu
path+="/usr/share/doc/git/contrib/diff-highlight"

# Get `python` to be brew python, see `brew info python` and
# https://github.com/Homebrew/homebrew-core/issues/15746
path=("/usr/local/opt/python/libexec/bin" $path)
# path=("/usr/local/opt/python@3.8/bin" $path)

path+=~/go/bin
export GOPATH=~/go

# Get Wireshark CLIs
path+=/Applications/Wireshark.app/Contents/MacOS

## Custom functionality
gitpic() {
    # filter out arguments *I* want to recognize; pass the rest on to git log
    for ((I = 0; I <= $#*; I++)); do
        case $*[$I] in
            -w|--when)
                # see below for behavior triggered by -w|--when
                local WHEN=1
                argv[$I]=
                ;;
            -h|--help)
                echo -en "Prints a pretty git ancestry tree.\n"\
                    "  All arguments not listed below are forwarded to \`git log\`.\n"\
                    "    -h, --help: Display this help and exit.\n"\
                    "    -w, --when: Append a date to the end of the log line.\n"
                return
                ;;
        esac
    done


    # base command
    # use alias so we get any default args
    local GITLOG=('git' 'l')
    # default options
    GITLOG+=('--color=always' '--graph')
    # format options
    # you can get a lot done by using %C(...)
    if [[ -n $WHEN ]]; then
        # -w|--when appends a relative date to the end of the log line (e.g., "two
        # days ago")
        GITLOG+=('--date=human' '--pretty=format:%C(auto)%h%d %ae%C(reset): %s (%cd)')
    else
        GITLOG+=('--pretty=format:%C(auto)%h%d %ae%C(reset): %s')
    fi
    # pass-thru args
    GITLOG+=("$*[@]")

    # Convoluted way to get zsh to generate our cyan color for us. (%) tells it
    # to do prompt expansion on the result. :- lets us provide a word directly
    # with no variable. Must quote word to prevent closing brace being seen.
    local -r BOLDCYAN="${(%):-"%F{cyan}"}"
    # set BOLDUSER to some other string if you want to highlight other names
    local -r BOLDUSER=$USER

    # $GITLOG: runs the accumulated command
    # perl: remove email domains
    # perl: make author name bold cyan if it's equal to $BOLDUSER (which defaults to $USER)
    #       only replace author name if it's followed by a colon (with an
    #       optional ANSI escape in the middle), so that we don't also replace
    #       the username in something like a branch name
    # less: pager; remove the R flag to see raw ANSI escape codes

    $GITLOG | \
        perl -pe "s/@[a-zA-Z0-9.-]+//" | \
        perl -pe "s/${BOLDUSER}((?:\e[^m]*?m)?:)/${BOLDCYAN}${BOLDUSER}\1/" | \
        less -FSRX
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

if [[ -f /usr/local/opt/asdf/asdf.sh ]]; then
    . /usr/local/opt/asdf/asdf.sh
elif [[ -f $HOME/.asdf/asdf.sh ]]; then
    . $HOME/.asdf/asdf.sh
fi

if hash direnv 2>/dev/null; then
  eval "$(direnv hook zsh)"
fi
