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
LPWD=$(pwd)
WORKDIR="${LPWD}/work"
INSTALL="/usr/local"
BUILDPKG="${WORKDIR}/git_build"
TINSTPKG="${WORKDIR}/git_install"
CONTAINERPKG="${WORKDIR}/Disk Image"

# ===========================================================================
# Hopefully you won't need to change anything below this point.  The
# definitions above are all that you need to build the package containers
# ===========================================================================

# Conditional define
if [[ "$(uname)" = "Darwin" ]]; then
	sed_regexp="-E"
else
	sed_regexp="-r"
fi

# Prepare some constants used everywhere
LAST_VERSION=$(curl http://git-scm.com/ 2>&1 | grep "<div id=\"ver\">" | sed ${sed_regexp} 's/^.+>v([0-9.]+)<.+$/\1/')
export GIT_VERSION="${1:-${LAST_VERSION}}"
export MACOSX_VERSION=$(sw_vers | grep "ProductVersion:" | cut -f 2 - | tr -d "." | cut -c 1-3)
if [[ "${MACOSX_VERSION}" = "106" ]]; then
	export PACKAGE_NAME="git-snowleopard-universal.pkg"
	export IMAGE_FILENAME="git-snowleopard-universal.dmg"
elif [[ "${MACOSX_VERSION}" = "105" ]]; then
	export PACKAGE_NAME="git-leopard-universal.pkg"
	export IMAGE_FILENAME="git-leopard-universal.dmg"
fi

# Internal functions to perform the complete build
function build_universal_binary {
	# Inform and start the build process
	echo "Building GIT $GIT_VERSION"
	# Prepare the work area
	[[ ! -d ${WORKDIR} ]] && \
		mkdir -p ${WORKDIR}
	# Go to the work area
	pushd ${WORKDIR}
	# Prepare the build stage
	[[ ! -d ${BUILDPKG} ]] && \
		mkdir -p ${BUILDPKG}
	# Go to the build stage and refresh it
	pushd ${BUILDPKG}
	[[ ! -f git-${GIT_VERSION}.tar.bz2 ]] && \
		curl -O http://kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.bz2
	[[ -d git-${GIT_VERSION} ]] && \
		rm -rf git-${GIT_VERSION}
	tar xjvf git-${GIT_VERSION}.tar.bz2
	# Enter the build package area and perform the build and temporary install
	pushd git-${GIT_VERSION}
	# If you're on PPC, you may need to uncomment this line: 
	echo "MOZILLA_SHA1=1" >> Makefile_tmp
	# Tell make to use $PREFIX/lib rather than MacPorts:
	echo "NO_DARWIN_PORTS=1" >> Makefile_tmp
	echo "NO_CROSS_DIRECTORY_HARDLINKS=1" >> Makefile_tmp
	cat Makefile >> Makefile_tmp
	mv Makefile_tmp Makefile
	# Build fat binaries with ppc and x86 with 32 and 64 bits support for
	# Leopard (10.5 => 105) and/or Snow Leopard (10.6 => 106).
	if [[ "${MACOSX_VERSION}" = "106" ]]; then
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 prefix=${INSTALL} all
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 prefix=${INSTALL} strip
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch ppc -arch i386 -arch x86_64" \
			 prefix=${INSTALL} DESTDIR=${TINSTPKG} install
	elif [[ "${MACOSX_VERSION}" = "105" ]]; then
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 prefix=${INSTALL} all
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 prefix=${INSTALL} strip
		make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386 -arch ppc64 -arch x86_64" \
			 prefix=${INSTALL} DESTDIR=${TINSTPKG} install
	fi
	# Add the contrib completion file
	mkdir -p ${TINSTPKG}/usr/local/share/git/contrib/completion
	cp contrib/completion/git-completion.bash ${TINSTPKG}/usr/local/share/git/contrib/completion/
	# Leave the build package area
	popd
	# Collect the man pages on the build stage and install them
	[[ ! -f git-manpages-${GIT_VERSION}.tar.bz2 ]] && \
		curl -O http://www.kernel.org/pub/software/scm/git/git-manpages-${GIT_VERSION}.tar.bz2
	mkdir -p ${TINSTPKG}/usr/local/share/man
	tar xjvo -C ${TINSTPKG}/usr/local/share/man -f git-manpages-${GIT_VERSION}.tar.bz2
	# Leave the build stage
	popd
	# Leave the work area
	popd
	# add .DS_Store to default ignore for new repositories
	echo ".DS_Store" >> "${TINSTPKG}/usr/local/share/git-core/templates/info/exclude"
	# Put the application on the final /Applications folder
	[[ ! -d "${TINSTPKG}/Applications" ]] && \
		mkdir -p "${TINSTPKG}/Applications" || \
		rm -rf "${TINSTPKG}/Applications/*"
	# Go to the $TINSTPKG/Applications to create the link
	pushd "${TINSTPKG}/Applications"
	ln -s "../usr/local/share/git-gui/lib/Git Gui.app" "Git Gui.app"
	# Leave the $TINSTPKG/Applications folder
	popd
	# Inform the build completion
	echo "Finished build GIT ${GIT_VERSION}"
	# End function
}

function build_package_container {
	# Prepare the stage and remove old installers
	[ ! -d ${CONTAINERPKG} ] && \
		mkdir -p ${CONTAINERPKG}
	[ -f ${CONTAINERPKG}/*.pkg ] && \
		rm -rf ${CONTAINERPKG}/*.pkg
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

# Main script... Collect build options first
# Run the binary build script
build_universal_binary
exit 0

# Prepare the package container
build_package_container



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

open "http://code.google.com/p/git-osx-installer/downloads/entry"
sleep 1
open "./"
