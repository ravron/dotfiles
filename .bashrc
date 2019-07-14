#PS4='+ $EPOCHREALTIME\011 '
#exec 3>&2 2>/tmp/bashstart.$$.log
#set -x

gitpic()
{
    # filter out arguments *I* want to recognize; pass the rest on to git log
    local ARGARR=("$@")
    for I in "${!ARGARR[@]}"; do
        case ${ARGARR[$I]} in
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
    local GITLOG="git l"
    # default options
    GITLOG+=" --color=always --graph"
    # format options
    # you can get a lot done by using %C(...)
    if [ $WHEN ]; then
        # -w|--when appends a relative date to the end of the log line (e.g., "two
        # days ago")
        GITLOG+=" --date=relative --pretty=format:\"%C(auto)%h%d %ae%C(reset): %s (%cd)\""
    else
        GITLOG+=" --pretty=format:\"%C(auto)%h%d %ae%C(reset): %s\""
    fi
    # pass-thru args
    GITLOG+=" ${ARGARR[@]}"

    local readonly BOLDCYAN=$(tput setaf 6)
    local readonly BOLDUSER=$USER
    # set BOLDUSER to some other string if you want to highlight other names
    #BOLDUSER='joebob'

    # eval: runs the command in $GITLOG (with extra args appended)
    # perl: remove email domains
    # perl: make author name bold cyan if it's equal to $BOLDUSER (which defaults to $USER)
    #       only replace author name if it's followed by a colon (with an
    #       optional ANSI escape in the middle), so that we don't also replace
    #       the username in something like a branch name
    # less: pager; remove the R flag to see raw ANSI escape codes

    eval $GITLOG | \
        perl -pe "s/@[a-zA-Z0-9.-]+//" | \
        perl -pe "s/${BOLDUSER}((?:\e[^m]*?m)?:)/${BOLDCYAN}${BOLDUSER}\1/" | \
        less -FSRX
}

# Makes ls color its output
export CLICOLOR=1
export LSCOLORS=gxFxCxDxbxexexaxaxaxex
# For `tree`
export LS_COLORS=${LSCOLORS}

# Makes grep always color its output unless piped elsewhere
export GREP_OPTIONS='--color=auto'

# Turn the below on to show + or * in the branch name. It's a little slow
# though.
#GIT_PS1_SHOWDIRTYSTATE=true
# See brew info bash-completion2
if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    . /usr/local/share/bash-completion/bash_completion
fi

jobsrunning() {
    if [[ -n $(jobs -r) ]] ; then
        echo -n ' %'
    fi
}

gitreponame() {
    if git rev-parse &> /dev/null ; then
        local -r path=$(git rev-parse --show-toplevel)

        # You can find the script at /usr/local/etc/bash_completion.d/git-prompt.sh
        echo -n " (${path##*/}/"
        # The second arg is an optional format arg
        __git_ps1 "%s)"
    fi
}

gh()
{
    local ORIGIN_URL
    ORIGIN_URL="$(git config --local remote.origin.url)" || return 1
    ORIGIN_URL=${ORIGIN_URL/://}
    ORIGIN_URL=${ORIGIN_URL/#git@/https://}
    ORIGIN_URL=${ORIGIN_URL%.git}

    local COMMIT_SHA

    local COMMIT_REF="HEAD"

    if [[ -n "$1" ]]; then
        COMMIT_REF="$1"
    fi

    local -r COMMIT_SHA="$(git rev-parse "$COMMIT_REF")"
    open "$ORIGIN_URL"/commit/"$COMMIT_SHA"
}

setstatus() {
    local -r STATUS="$([[ -d .git ]] && git rev-parse --abbrev-ref HEAD || \
        echo "Not a repo")"
    ~/.iterm2/it2setkeylabel set status "$STATUS" &> /dev/null
}

rgbcolor() {
    # Pass three args, each in [0, 255] for RGB
    if (( $# != 3 )) ; then
        echo 'wrong number of args to rgbcolor' >&2
        echo 'ERR'
        return 1
    fi
    echo -n $'\E'"[38;2;$1;$2;$3m"
}

# check https://www.kirsle.net/wizards/ps1.html
export PS1=                    # Clear PS1 and mark for export
PS1+="\$(setstatus)"
PS1+="\[$(rgbcolor 255 255 255)\]"    # Set color to bright white
PS1+="▶ "                      # Print a Unicode pointer
# PS1+="\! "                     # Print the history number, for use in history substitution
PS1+="\[$(tput setaf 6)\]"     # Set color to cyan
PS1+="\W"                      # Current working dir
PS1+="\[$(tput setaf 4)\]"     # Set color to blue
# The following line causes gitreponame to be evaluated on each print of the PS1
PS1+="\$(gitreponame)"
PS1+="\[$(tput setaf 5)\]"     # Set color to magenta
PS1+="\$(jobsrunning)"         # Print a % if there are jobs running
PS1+="\[$(tput setaf 1)\]"     # Set color to red
PS1+=" \\$ "                   # Literal dollar sign
PS1+="\[$(tput sgr0)\]"        # Turn off colors

HISTFILESIZE=10000
HISTSIZE=-1
# Show 8601 dates before each history entry
HISTTIMEFORMAT="%F %T "

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
export LESS_TERMCAP_md=$(tput setaf 3)  # yellow for starting bold
export LESS_TERMCAP_us=$(tput setaf 4)  # blue for starting underline
export LESS_TERMCAP_me=$(tput sgr0)  # reset for ending bold
export LESS_TERMCAP_ue=$(tput sgr0)  # reset for ending underline

# Location aliases
alias src="cd ~/src"
alias scratch="cd ~/scratch"

# Command aliases
alias ll="ls -ahl"
alias g="git"
alias gp="gitpic"
alias date8601="date -u +'%Y-%m-%dT%H:%M:%SZ'"
# The pattern in awk makes sure we don't touch the branch currently checked out
# (or try to git branch -D * !!)
# gdg for "git delete gone"
alias gdg="git branch --verbose | \
    grep --fixed-strings [gone] | \
    awk '!/^\*/ {print \$1}' | \
    xargs git branch --delete --force"
alias s2a="saml2aws login \
    --force \
    --profile default \
    --duo-mfa-option Passcode \
    --skip-prompt"
# alias vo='vim $(fzf --height 30%)'

# Make code completion for git work for g. See
# /usr/local/etc/bash_completion.d/git-completion.bash
__git_complete g __git_main
__git_complete gitpic _git_log
__git_complete gp _git_log

# Add diff-highlight executable to PATH. See
# https://github.com/git/git/tree/master/contrib/diff-highlight
export PATH="$(brew --prefix)/share/git-core/contrib/diff-highlight:$PATH"

# Use vim mode
set -o vi

# Enable globstar
shopt -s globstar

# Enable noclobber. Prevents existing files from being overwritten by
# redirection. Override noclobber using the >| redirection operator.
set -C

# Treat expansion of unbound variables as an error (see `help set`)
# Causes an error on every line for me ("-bash: ZSH_VERSION: unbound variable")
# This error comes from git-prompt.sh, installed with homebrew's bash-completion
# formula. They do [ -z "$ZSH_VERSION" ]. When ZSH_VERSION is unset, and set -u
# is enabled, you get that error. See
# http://stackoverflow.com/a/13864829/1292061
# set -u

#set +x
#exec 2>&3 3>&-

# Get `python` to be brew python, see `brew info python` and
# https://github.com/Homebrew/homebrew-core/issues/15746
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

[ -f ~/.bashrc_private ] && source ~/.bashrc_private

# nvm's setup is slow and I don't use it often. Lazy load it by wrapping it in a
# function by the same name. When first invoked in a session, unset the wrapper,
# load the real nvm, and invoke it with the provided parameters. The
# NVM_SYMLINK_CURRENT causes nvm to create a symlink to the current node at
# ~/.nvm/current. It's not great, because it breaks the session model of nvm,
# but I almost never change it anyways, and that fixes tools like WebStorm.
export NVM_SYMLINK_CURRENT=true
nvm() {
    unset ${FUNCNAME[0]}
    # See brew info nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
    [ -s "/usr/local/etc/bash_completion.d/nvm" ] && \. "/usr/local/etc/bash_completion.d/nvm"
    nvm "$@"
}
export PATH=$PATH:~/.nvm/current/bin

# See brew info fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type directory'

cds() {
    local -r DIR=$(
        cd ~/src
        fd --type directory --max-depth 2 --exclude /go . | fzf
    )
    [[ -n "$DIR" ]] && cd ~/src/"$DIR"
}
# export FZF_DEFAULT_OPTS='--preview "head -200 {}"'

export ANDROID_SDK_ROOT=~/Library/Android/sdk

# See brew info go
export PATH=$PATH:/usr/local/opt/go/libexec/bin

# Get installed go binaries in PATH
export PATH=$PATH:/Users/ravron/src/go/bin

# See man fasd
eval "$(fasd --init auto)"
alias v='f -e vim'

# See go help modules
export GO111MODULE=on

#set +x
#exec 2>&3 3>&-
