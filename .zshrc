# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory beep nomatch extendedglob
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
PROMPT+='▶ '
PROMPT+='%F{cyan}'
# Current working dir
PROMPT+='%1~ '
PROMPT+='%F{blue}'
PROMPT+='${vcs_info_msg_0_}'
PROMPT+='%F{red}'
PROMPT+='$ '
# Turn off colors
PROMPT+='%f'

## Key bindings
# Use vim bindings
bindkey -v
bindkey "^R" history-incremental-search-backward

## Misc zsh
# Turn off inverse on pasted text
zle_highlight=('paste:none')

## Command aliases
alias ll="ls -ahl"
alias g="git"
alias gp="gitpic"
alias date8601="date -u +'%Y-%m-%dT%H:%M:%SZ'"
# The pattern in awk makes sure we don't touch the branch currently checked out
# (or try to git branch -D * !!)
# gdg for "git delete gone"
alias gdg="git branch --verbose | \
    grep --fixed-strings '[gone]' | \
    awk '!/^\*/ {print \$1}' | \
    xargs git branch --delete --force"
alias s2a="saml2aws login \
    --force \
    --profile default \
    --duo-mfa-option Passcode \
    --skip-prompt"

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

# Make vim the default editor
export EDITOR=vim

LESS_ARR=(
# Case insensitive searching if search term doesn't contain an uppercase letter
'--ignore-case'
# Output ANSI color control characters directly. Useful to preserve color.
'--RAW-CONTROL-CHARS'
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

# nvm's setup is slow and I don't use it often. Lazy load it by wrapping it in a
# function by the same name. When first invoked in a session, unset the wrapper,
# load the real nvm, and invoke it with the provided parameters. The
# NVM_SYMLINK_CURRENT causes nvm to create a symlink to the current node at
# ~/.nvm/current. It's not great, because it breaks the session model of nvm,
# but I almost never change it anyways, and that fixes tools like WebStorm.
export NVM_SYMLINK_CURRENT=true
nvm() {
    unset nvm
    # See brew info nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
    [ -s "/usr/local/etc/bash_completion.d/nvm" ] && \. "/usr/local/etc/bash_completion.d/nvm"
    nvm "$@"
}
path+=~/.nvm/current/bin

# See brew info fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type directory'
# Use fd instead of find when triggered with **<tab>
# See /usr/local/opt/fzf/shell/completion.zsh
_fzf_compgen_path() {
    echo "$1"
    fd --hidden --follow --type directory --type file --type symlink --exclude .git . "$1"
}
_fzf_compgen_dir() {
    fd --hidden --follow --type directory --exclude .git . "$1"
}

# See man fasd
eval "$(fasd --init auto)"
alias v='f -e vim'

export RIPGREP_CONFIG_PATH=~/.config/rg/rg_config

## Add things to the PATH
# For an explanation of how this `path+=…` works, see
# http://zsh.sourceforge.net/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell

# Add diff-highlight executable to PATH. See
# https://github.com/git/git/tree/master/contrib/diff-highlight
path+="$(brew --prefix)/share/git-core/contrib/diff-highlight"

# Get `python` to be brew python, see `brew info python` and
# https://github.com/Homebrew/homebrew-core/issues/15746
path=("/usr/local/opt/python/libexec/bin" $path)

path+=~/src/go/bin

## Custom functionality
gitpic() {
    # filter out arguments *I* want to recognize; pass the rest on to git log
    for ((I = 0; I <= $#*; I++)); do
        case $*[$I] in
            -w|--when)
                # see below for behavior triggered by -w|--when
                local WHEN=1
                unset ARGARR[$I]
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
        GITLOG+=('--date=relative' '--pretty=format:%C(auto)%h%d %ae%C(reset): %s (%cd)')
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
