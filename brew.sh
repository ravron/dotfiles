#!/usr/bin/env bash

set -eu

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Install and/or upgrade everything in the Brewfile
brew bundle

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
cpan Net::SMTP::SSL MIME::Base64 Authen::SASL Term::ReadKey 2>/dev/null

# Remove outdated versions from the cellar.
brew cleanup
