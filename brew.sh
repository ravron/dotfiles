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

# git send-email uses perl, but requires additional perl modules. Further, git
# doesn't require the perl brew formula, and won't use the brewed perl unless
# you pass --with-perl. Thus:
#   1. Install brew's perl
#   2. Use brewed perl's cpan to install the three required modules for
#      send-email.
#   3. Install git and use --with-perl to point it at the brewed perl.
# See https://github.com/Homebrew/homebrew-core/issues/12870 for further
# information.
brew install perl 2>/dev/null
cpan Net::SMTP::SSL MIME::Base64 Authen::SASL 2>/dev/null
brew install git --with-perl 2>/dev/null

brew install imagemagick 2>/dev/null
brew install tree 2>/dev/null
brew install jq 2>/dev/null

# Critical utilities
brew install cowsay 2>/dev/null
brew install figlet 2>/dev/null

# python installs python 3 now
brew install python 2>/dev/null
# Get a newer version of python2 as well
brew install python@2 2>/dev/null

# Installs brew rmtree, for removing trees of brew deps
brew tap beeftornado/rmtree

# Remove outdated versions from the cellar.
brew cleanup 2>/dev/null
