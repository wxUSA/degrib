#!/bin/bash
#
dnf -y groupinstall 'Development Tools'
dnf -y install epel-release
crb enable
dnf -y install zlib-devel libpng-devel minizip-devel libxml2-devel tcl tcl-devel tk-devel
#mkdir degrib && cd degrib
#wget https://lamp.mdl.nws.noaa.gov/lamp/Data/degrib/download/degrib-src.tar.gz
git clone https://github.com/wxUSA/degrib
cd degrib/src
./configure CFLAGS="-O3" TCL_PREFIX=/usr TCL_VERSION=$(echo 'puts $tcl_version;'|tclsh)
make 2>&1 | tee make.out
