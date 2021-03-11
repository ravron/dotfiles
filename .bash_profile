# .bash_profile is run once, at login time. .bashrc is run for each subshell
# start.
# All configuration happens in .bashrc. Just source that.
source ~/.bashrc

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH="$HOME/.cargo/bin:$PATH"
