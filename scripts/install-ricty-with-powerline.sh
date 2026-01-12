#!/bin/sh

brew tap sanemat/font
brew install ricty --with-powerline

# copy font
cp -f /opt/homebrew/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
# clear font cache
fc-cache -vf
