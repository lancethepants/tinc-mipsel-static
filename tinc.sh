#!/bin/bash

set -e
set -x

mkdir ~/tinc && cd ~/tinc

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncursesw"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET https://zlib.net/zlib-1.2.11.tar.gz
tar zxvf zlib-1.2.11.tar.gz
cd zlib-1.2.11

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/opt \
--static

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# LZO # #####################################################################
####### #####################################################################

mkdir $SRC/lzo && cd $SRC/lzo
$WGET http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
tar zxvf lzo-2.10.tar.gz
cd lzo-2.10

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-1.0.2o.tar.gz
tar zxvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o

./Configure linux-mips32 \
-mtune=mips32 -mips32 -ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/opt zlib \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

make CC=mipsel-linux-gcc
make CC=mipsel-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

########### #################################################################
# NCURSES # #################################################################
########### #################################################################

mkdir $SRC/curses && cd $SRC/curses
$WGET http://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
tar zxvf ncurses-6.1.tar.gz
cd ncurses-6.1

LDFLAGS=$LDFLAGS \
CPPFLAGS="-P $CPPFLAGS" \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-widec \
--enable-overwrite \
--with-normal \
--with-shared \
--enable-rpath \
--with-fallbacks=xterm \
--without-progs

$MAKE
make install DESTDIR=$BASE

ln -s libncursesw.a $DEST/lib/libcurses.a

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

mkdir $SRC/libreadline && cd $SRC/libreadline
$WGET http://ftp.gnu.org/gnu/readline/readline-7.0.tar.gz
tar zxvf readline-7.0.tar.gz
cd readline-7.0

$WGET https://raw.githubusercontent.com/lancethepants/tomatoware/master/patches/readline/readline.patch
patch < readline.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-shared \
bash_cv_wcwidth_broken=no \
bash_cv_func_sigsetjmp=yes

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# TINC 1.0 # ################################################################
############ ################################################################

#mkdir $SRC/tinc1.0 && cd $SRC/tinc1.0
#$WGET https://www.tinc-vpn.org/packages/tinc-1.0.34.tar.gz
#tar zxvf tinc-1.0.34.tar.gz
#cd tinc-1.0.34

#LDFLAGS=$LDFLAGS \
#CPPFLAGS=$CPPFLAGS \
#CFLAGS=$CFLAGS \
#CXXFLAGS=$CXXFLAGS \
#$CONFIGURE \
#--disable-hardening \
#--localstatedir=/var \
#--with-zlib=$DEST \
#--with-lzo=$DEST \
#--with-openssl=$DEST \

#$MAKE LIBS="-static -lcrypto -ldl -llzo2 -lz"
#make install DESTDIR=$BASE/tinc1.0 LIBS="-static -lcrypto -llzo2 -lz"

############ ################################################################
# TINC 1.1 # ################################################################
############ ################################################################

mkdir $SRC/tinc1.1 && cd $SRC/tinc1.1
$WGET https://www.tinc-vpn.org/packages/tinc-1.1pre15.tar.gz
tar zxvf tinc-1.1pre15.tar.gz
cd tinc-1.1pre15

LDFLAGS="-static $LDFLAGS" \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
./configure \
--host=mipsel-linux \
--prefix=/usr \
--sysconfdir=/etc \
--localstatedir=/var \
--with-zlib=$DEST \
--with-lzo=$DEST \
--with-openssl=$DEST \
--with-curses=$DEST \
--with-readline=$DEST

$MAKE
