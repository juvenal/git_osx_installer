#!/bin/sh
#
#
#
#

# Prepare some internal variables
PREFIX=/usr/local
DESTDIR=`pwd`

# Start the build process
echo "Building GIT $GIT_VERSION"

[ ! -d git_build ] && \
	mkdir -p git_build

pushd git_build
    [ ! -f git-$GIT_VERSION.tar.bz2 ] && \
        curl -O http://kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.bz2
    rm -rf git-$GIT_VERSION && \
        tar jxvf git-$GIT_VERSION.tar.bz2
    pushd git-$GIT_VERSION
        # If you're on PPC, you may need to uncomment this line: 
        # echo "MOZILLA_SHA1=1" >> Makefile_tmp

        # Tell make to use $PREFIX/lib rather than MacPorts:
        echo "NO_DARWIN_PORTS=1" >> Makefile_tmp
		echo "NO_CROSS_DIRECTORY_HARDLINKS=1" >> Makefile_tmp
        cat Makefile >> Makefile_tmp
        mv Makefile_tmp Makefile

		# Make fat binaries with ppc/32 bit/64 bit
        make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             prefix=$PREFIX all
        make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             prefix=$PREFIX strip
        make CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc -arch i386" \
             prefix=$PREFIX DESTDIR=$DESTDIR install

        # contrib
        mkdir -p $DESTDIR/usr/local/share/git/contrib/completion
        cp contrib/completion/git-completion.bash $DESTDIR/usr/local/share/git/contrib/completion/
    popd
    
    [ ! -f git-manpages-$GIT_VERSION.tar.bz2 ] && \
        curl -O http://www.kernel.org/pub/software/scm/git/git-manpages-$GIT_VERSION.tar.bz2
    mkdir -p $DESTDIR/usr/local/share/man
    tar xjvo -C $DESTDIR/usr/local/share/man -f git-manpages-$GIT_VERSION.tar.bz2
popd

# add .DS_Store to default ignore for new repositories
sh -c "echo .DS_Store >> $DESTDIR/usr/local/share/git-core/templates/info/exclude"

# Inform the build completion
echo "Finished build GIT_VERSION $GIT_VERSION"
