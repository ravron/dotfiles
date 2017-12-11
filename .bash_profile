# .bash_profile is run once, at login time. .bashrc is run for each subshell
# start.
# All configuration happens in .bashrc. Just source that.
source ~/.bashrc

# Android SDK/NDK setup
export ANDROID_HOME="/Users/ravron/Library/Android/sdk/"
export ANDROID_NDK_HOME="/Users/ravron/.android-ndk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_NDK_HOME"

# Android SDK/NDK and Buck setup
export PATH="/Users/ravron/Library/Android/buck/bin:$PATH"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
