# PS4='+ $(gdate "+%s.%N")\011 '
# exec 3>&2 2>/tmp/bashstart.$$.log
# set -x

echocmd()
{
    echo "$ $@"
    "$@"
    return
}

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
    local GITLOG="git log"
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
    # sed: remove email domains
    # sed: make author name bold cyan if it's equal to $BOLDUSER (which defaults to $USER)
    # less: page that baby; remove the R flag to see raw ANSI escape codes

#    eval $GITLOG | sed -E "s/@[a-zA-Z0-9.]+//" | \
#        sed -E "s/${BOLDUSER}((\e[^m]*m)?:)/${BOLDCYAN}${BOLDUSER}\1/" | \
#        less -FSRX

    # eval: runs the command in $GITLOG (with extra args appended)
    # perl: remove email domains
    # perl: make author name bold cyan if it's equal to $BOLDUSER (which defaults to $USER)
    #       only replace author name if it's followed by a colon (with an
    #       optional ANSI escape in the middle), so that we don't also replace
    #       the username in something like a branch name
    # less: page that baby; remove the R flag to see raw ANSI escape codes

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
    local j=$(jobs)
    # When the shell is started, jobs reports a job matching this pattern has just
    # finished. This early exit prevents that edge case from causing us to say
    # that jobs are running.
    if [[ $j == *SHELL_SESSION_HISTFILE_NEW* ]] ; then
        exit
    fi
    if [ "$j" ] ; then
        echo -n ' %'
    fi
}

gitreponame() {
    if git rev-parse &> /dev/null ; then
        local path=$(git rev-parse --show-toplevel)

        # You can find the script at /usr/local/etc/bash_completion.d/git-prompt.sh
        echo -n " (${path##*/}/"
        # The second arg is an optional format arg
        __git_ps1 "%s)"
    fi
}

# check https://www.kirsle.net/wizards/ps1.html
#export PS1="\W \u\[$(tput setaf 4)\]\$(__git_ps1 \" (%s)\")\[$(tput setaf 1)\]\\$ \[$(tput sgr0)\]"
export PS1=                    # Clear PS1 and mark for export
PS1+="\[$(tput setaf 15)\]"    # Set color to bright white
#export PS1+="■▶ "             # Print a Unicode pointer
PS1+="▶ "                      # Print a Unicode pointer
PS1+="\! "                     # Print the history number, for use in history substitution
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

# Make vim the default editor
export EDITOR=vim

# Location aliases
alias src="cd ~/src"
alias xp="cd ~/src/xplat"
alias mm="cd ~/src/mobile-misc"
alias db="cd ~/src/xplat/dbapp-ios/Dropbox"
alias scratch="cd ~/scratch"
alias release="cd ~/src/xplat/tools/release/ios/dbapp"
alias aut="cd ~/src/xplat/dbapp-ios/Dropbox/Tests/Automata/Tests"
alias autgit="cd ~/src/xplat/dbapp-ios/automata"

# Command aliases
alias ox="open Dropbox.xcodeproj"
alias ll="ls -ahl"
alias g="git"
alias gp="gitpic"
alias xsu="~/src/xplat/submodule_update.sh"
# Exclude these damn files from rg search
alias rg="rg -g '!*.xcactivitylog'"
alias date8601="date -u +'%Y-%m-%dT%H:%M:%SZ'"

# Make code completion for git work for g. See
# /usr/local/etc/bash_completion.d/git-completion.bash
__git_complete g __git_main

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

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/src/misc/gregprice/stacked-diffs"
# Get `python` to be brew python, see `brew info python` and https://github.com/Homebrew/homebrew-core/issues/15746
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

source ~/src/oss/GitChildBranchHelpers/bash_zsh_git_helper_aliases.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/google-cloud-sdk/path.bash.inc' ]; then source '/usr/local/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/google-cloud-sdk/completion.bash.inc' ]; then source '/usr/local/google-cloud-sdk/completion.bash.inc'; fi

# set +x
# exec 2>&3 3>&-