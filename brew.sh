#!/usr/bin/env bash

set -eu

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Tap and install ripgrep
brew tap burntsushi/ripgrep https://github.com/BurntSushi/ripgrep.git
brew install burntsushi/ripgrep/ripgrep-bin 2>/dev/null

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash 2>/dev/null
brew install bash-completion2 2>/dev/null

# Switch to using brew-installed bash as default shell
if ! grep -q '/usr/local/bin/bash' /etc/shells; then
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
    chsh -s /usr/local/bin/bash;
fi;

# Install GnuPG to enable PGP-signing commits.
brew install gnupg 2>/dev/null

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi 2>/dev/null

brew install git 2>/dev/null
brew install cowsay 2>/dev/null
brew install figlet 2>/dev/null
brew install imagemagick 2>/dev/null
brew install tree 2>/dev/null

# TODO: Python3
brew install python 2>/dev/null
brew install python3 2>/dev/null

# Remove outdated versions from the cellar.
brew cleanup 2>/dev/null
