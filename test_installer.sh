#!/bin/sh
#
# BOKEN CONCEPT.... DON'T USE THIS THING!!!
#
# FIX THE ACTUAL STUPID IDEA FIRST!!!!!
#

echo "Testing..."
#sudo rm /etc/paths.d/git
#sudo rm /etc/manpaths.d/git
#sudo rm -rf /usr/local

echo "OK - running the installer. Come back and press a key when you're done."
open Disk\ Image/git*.pkg 

read -n 1

for file in /etc/paths.d/git /etc/manpaths.d/git /usr/local/bin/git "/usr/local/share/git-gui/lib/Git Gui.app/Contents/Info.plist"; do
  printf "'$file'"
  if [ -f "$file" ]; then
    echo " - exists..."
  else
    echo " DOES NOT EXIST!"
    echo "FAIL FAIL FAIL ALL CAPS FAT KID IN DODGE BALL FAIL"
    exit 1
  fi
done

echo "Success!"

