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

# Define some destinations
WORKDIR=$(pwd)
INSTALL="/usr/local"
BUILDPKG="${WORKDIR}/git_build"
TINSTPKG="${WORKDIR}/git_install"
CONTAINERPKG="${WORKDIR}/Disk Image"

# ===========================================================================
# Hopefully you won't need to change anything below this point.  The
# definitions above are all that you need to build the package containers
# ===========================================================================

# Conditional define
if [ "$(uname)" == "Darwin" ]; then
	sed_regexp="-E"
else
	sed_regexp="-r"
fi

# Prepare some constants used everywhere
LAST_VERSION=$(curl http://git-scm.com/ 2>&1 | grep "<div id=\"ver\">" | sed ${sed_regexp} 's/^.+>v([0-9.]+)<.+$/\1/')
export GIT_VERSION="${1:-${LAST_VERSION}}"
export PACKAGE_NAME="git-${GIT_VERSION}-leopard"
export IMAGE_FILENAME="git-${GIT_VERSION}-leopard.dmg" 

# Internal functions to perform the complete build
function build_universal_binary {
	# Inform and start the build process
	echo "Building GIT $GIT_VERSION"
	# Go to the build area
	pushd ${WORKDIR}
	[ ! -d ${BUILDPKG} ] && \
		mkdir -p ${BUILDPKG}
	# Go to the build area and refresh it
	pushd ${BUILDPKG}
	[ ! -f git-${GIT_VERSION}.tar.bz2 ] && \
		curl -O http://kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.bz2
	[ -d git-${GIT_VERSION} ] && \
		rm -rf git-${GIT_VERSION}
	tar xjvf git-${GIT_VERSION}.tar.bz2
	# Enter and perform the build and install
	pushd git-${GIT_VERSION}
	# If you're on PPC, you may need to uncomment this line: 
	# echo "MOZILLA_SHA1=1" >> Makefile_tmp
	# Tell make to use $PREFIX/lib rather than MacPorts:
	echo "NO_DARWIN_PORTS=1" >> Makefile_tmp
	echo "NO_CROSS_DIRECTORY_HARDLINKS=1" >> Makefile_tmp
	cat Makefile >> Makefile_tmp
	mv Makefile_tmp Makefile
	# Build fat binaries with ppc and i386 code for Leopard (10.5) 32 and 64 bits
	make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 prefix=${INSTALL} all
	make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 prefix=${INSTALL} strip
	make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
		 prefix=${INSTALL} DESTDIR=${TINSTPKG} install
	# Add the contrib completion file
	mkdir -p ${TINSTPKG}/usr/local/share/git/contrib/completion
	cp contrib/completion/git-completion.bash ${TINSTPKG}/usr/local/share/git/contrib/completion/
	popd
	# Collect and install the man pages
	[ ! -f git-manpages-${GIT_VERSION}.tar.bz2 ] && \
		curl -O http://www.kernel.org/pub/software/scm/git/git-manpages-${GIT_VERSION}.tar.bz2
	[ -d ${TINSTPKG}/usr/local/share/man ] && \
		rm -rf ${TINSTPKG}/usr/local/share/man
	mkdir -p ${TINSTPKG}/usr/local/share/man
	tar xjvo -C ${TINSTPKG}/usr/local/share/man -f git-manpages-${GIT_VERSION}.tar.bz2
	popd
	popd
	# add .DS_Store to default ignore for new repositories
	echo ".DS_Store" >> "${TINSTPKG}/usr/local/share/git-core/templates/info/exclude"
	# Inform the build completion
	echo "Finished build GIT ${GIT_VERSION}"
	# End function
}

function build_package_container {
	# Define some local variables
	local DESTDIR=${1}
	local CONTAINER=${2}
	# Prepare the stage and remove old installers
	[ ! -d ${CONTAINER} ] && \
		mkdir -p ${CONTAINER}
	[ -f ${CONTAINER}/*.pkg ] && \
		rm -rf ${CONTAINER}/*.pkg
	# Categorize the app
	# First of all prepare the application folder structure
	rm -rf gitApp-${GIT_VERSION}
	rm -rf gitCmdLn-${GIT_VERSION}
	mkdir -p gitApp-${GIT_VERSION}/component
	mkdir -p gitCmdLn-${GIT_VERSION}/component
	mkdir -p gitCmdLn-${GIT_VERSION}/extras
	# Fill the components and extras for the gitApp part
	[ -d gitApp-${GIT_VERSION}/extras
	# Now fill it with the needed files
	cp -r ${DESTDIR}/usr/local/* gitCmdLn-${GIT_VERSION}/component
	cat 
	# Fill the components and extras for the gitCmdLn part
	[ -d gitCmdLn-${GIT_VERSION}/component
	
	# End function
}

# Run the binary build script
build_universal_binary
exit 0
# Prepare the package container
build_package_container ${BUILDPKG} ${CONTAINERPKG}



#mkdir gitCmdLn && mv usr/local/* gitCmdLn
exit 0

SCCS = http://downloads.sourceforge.net/project/cssc/cssc/1.0.1/CSSC-1.0.1.tar.gz?use_mirror=ufpr
http://sourceforge.net/projects/cssc/files/cssc/1.0.1/CSSC-1.0.1.tar.gz/download

CVSps = http://www.cobite.com/cvsps/cvsps-2.2b1.tar.gz

cat > file.xxx << __END__



__END__




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
