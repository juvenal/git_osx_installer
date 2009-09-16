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

# Conditional define
if [ "`uname`" == "Darwin" ]; then
	sed_regexp="-E"
else
	sed_regexp="-r"
fi

# Prepare some constants used everywhere
LAST_VERSION=`curl http://git-scm.com/ 2>&1 | grep "<div id=\"ver\">" | sed ${sed_regexp} 's/^.+>v([0-9.]+)<.+$/\1/'`
export GIT_VERSION="${1:-${LAST_VERSION}}"
export PACKAGE_NAME="git-${GIT_VERSION}-leopard"
export IMAGE_FILENAME="git-${GIT_VERSION}-leopard.dmg" 

# Prepare the stage and remove old installers
[ ! -d Disk\ Image ] && \
	mkdir -p Disk\ Image
[ -f Disk\ Image/*.pkg ] && \
	rm Disk\ Image/*.pkg

# Run the binary build script
./build_universal_binary.sh

# Categorize the app
# First of all prepare the folder structure
[ ! -d gitCmdLn-${GIT_VERSION} ] && \
	mkdir gitCmdLn-${GIT_VERSION}
[ ! -d gitCmdLn-${GIT_VERSION}/component ] && \
	mkdir gitCmdLn-${GIT_VERSION}/component
[ ! -d gitCmdLn-${GIT_VERSION}/extras ] && \
	mkdir -p gitCmdLn-${GIT_VERSION}/extras
# Now fill it with the needed filed

[ -d gitCmdLn-${GIT_VERSION}/component/* ] && \
	rm -rf gitCmdLn-${GIT_VERSION}/component/* && \
	cp -r usr/local/* gitCmdLn-${GIT_VERSION}/component
[ -f gitCmdLn-${GIT_VERSION}/extras/* ] && \
	rm -rf gitCmdLn-${GIT_VERSION}/extras/* && \
	cat > file.xxx << __END__



__END__

#mkdir gitCmdLn && mv usr/local/* gitCmdLn
exit 0

SCCS = http://downloads.sourceforge.net/project/cssc/cssc/1.0.1/CSSC-1.0.1.tar.gz?use_mirror=ufpr
http://sourceforge.net/projects/cssc/files/cssc/1.0.1/CSSC-1.0.1.tar.gz/download

CVSps = http://www.cobite.com/cvsps/cvsps-2.2b1.tar.gz





# Print some information
echo $PACKAGE_NAME | pbcopy
echo "Git version is $GIT_VERSION"

# Build the package
/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker --doc Git\ Installer.pmdoc/ -o Disk\ Image/git-$GIT_VERSION-leopard.pkg --title "Git $GIT_VERSION"

#echo "Testing the installer..."
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
