#!/usr/bin/env bash

set -eu

# Install homebrew if necessary
if command -v brew &> /dev/null; then
    read -p 'Homebrew not found. Install it? (y/N) ' -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo 'Installing Homebrew...'
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo 'You can install it manually from https://brew.sh/. Exiting.'
        exit 1
    fi
fi

# Install command-line tools using Homebrew. This script uses the brew bundle
# functionality. See https://github.com/Homebrew/homebrew-bundle.
# To add new things, brew bundle dump --describe --force

# Install or upgrade everything in the Brewfile
brew bundle install

# Switch to using brew-installed bash as default shell
if ! grep -q '/usr/local/bin/bash' /etc/shells; then
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash
fi;

# git send-email uses perl, but requires additional perl modules. Further, git
# doesn't require the perl brew formula, and won't use the brewed perl unless
# you pass --with-perl. Thus:
#   1. Install brew's perl
#   2. Use brewed perl's cpan to install the three required modules for
#      send-email.
#   3. Install git and use --with-perl to point it at the brewed perl.
# See https://github.com/Homebrew/homebrew-core/issues/12870 for further
# information.
# aaand the interactive.singleKey config requires Term::ReadKey, which
# apparently doesn't come standard with the brew perl. Maybe this isn't worth it
# just to get send-email working.
# -T: don't run tests
cpan -T Net::SMTP::SSL MIME::Base64 Authen::SASL Term::ReadKey 2>/dev/null

# Remove outdated versions from the cellar.
brew cleanup
brew cask cleanup --outdated
