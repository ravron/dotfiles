#!/usr/bin/env bash

set -eux

# Spectacle.app configuration
cp -R init/spectacle.json ~/Library/Application\ Support/Spectacle/Shortcuts.json 2> /dev/null
