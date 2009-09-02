#!/bin/bash
#
#
#
#
#
#
#
#
#
#

# Prepare some constants used everywhere
export GIT_VERSION="${1:-`curl http://git-scm.com/ 2>&1 | grep "<div id=\"ver\">" | sed $sed_regexp 's/^.+>v([0-9.]+)<.+$/\1/'`}"
export PACKAGE_NAME="git-$GIT_VERSION-leopard"
export IMAGE_FILENAME="git-$GIT_VERSION-leopard.dmg" 

# Prepare the stage and remove old installers
[ ! -d Disk\ Image ] && \
	mkdir -p Disk\ Image
rm Disk\ Image/*.pkg

# Run the binary build script
./build_universal_binary.sh

# Print some information
echo $PACKAGE_NAME | pbcopy
echo "Git version is $GIT_VERSION"

# Build the package
/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker --doc Git\ Installer.pmdoc/ -o Disk\ Image/git-$GIT_VERSION-leopard.pkg --title "Git $GIT_VERSION"

echo "Testing the installer..."

#./test_installer.sh

#printf "$GIT_VERSION" | pbcopy

UNCOMPRESSED_IMAGE_FILENAME="git-$GIT_VERSION-leopard.uncompressed.dmg"
hdiutil create $UNCOMPRESSED_IMAGE_FILENAME -srcfolder "Disk Image" -volname "Git $GIT_VERSION Leopard" -ov
hdiutil convert -format UDZO -o $IMAGE_FILENAME $UNCOMPRESSED_IMAGE_FILENAME
rm $UNCOMPRESSED_IMAGE_FILENAME

echo "Git Installer $GIT_VERSION - OS X - Leopard - Universal Binary" | pbcopy
open "http://code.google.com/p/git-osx-installer/downloads/entry"
sleep 1
open "./"
