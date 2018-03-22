# ravron's dotfiles
**WARNING:** Do not use any of these configuration files, nor execute any of these scripts, until you've reviewed and understood them yourself.

## Installation
Clone the repo and run `boostrap.sh`. This script pulls the tip of master and symlinks its configuration files into `$HOME`. It will refuse to overwrite existing files, for your protection.

### Homebrew
Run `brew.sh`. If you don't have Homebrew installed, `brew.sh` will ask if you'd like to try to install it automatically before proceeding. Otherwise, the script installs a number of traditional brew formulae as well as some GUI apps via [`brew cask`](https://caskroom.github.io/).

### Vim
Run `vim.sh`. This script installs vim packages. Note that native vim packages require vim 8.0+; macOS before 10.13 ships with 7.4. The Homebrew installation, above, installs the latest vim and makes it the default, so if you've run that, then `vim.sh` will work correctly.

### Miscellaneous
The [`init`](https://github.com/ravron/dotfiles/tree/master/init) directory contains a customized configuration for macOS's Terminal.app which is closely modeled after [tomislav's dark configuration](https://github.com/tomislav/osx-terminal.app-colors-solarized), but swaps the highlight and cursor colors. Double-click it to install it to Terminal.app, and set it as default in settings.
