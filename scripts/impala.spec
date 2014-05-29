%global impala_uid          411460044
%global impala_gid          411460016
%global impala_user         impala

%define major_ver           IMPALA_VERSION
%define hadoop_ver          HADOOP_VERSION_REPLACE
%define hive_ver            HIVE_VERSION_REPLACE
%define service_name        alti-impala
%define company_prefix      altiscale
%define pkg_name            %{service_name}-%{major_ver}
%define install_impala_dest /opt/%{pkg_name}
%define build_release       BUILD_TIME

# Define installation folder
%define libdir              /usr/lib/impala/

Name: %{service_name}
Summary: %{pkg_name} RPM Installer
Version: %{major_ver}
Release: %{build_release}%{?dist}
License: Copyright (C) 2014 Altiscale. All rights reserved.
Source: %{_sourcedir}/%{service_name}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%{service_name}
Requires: vcc-hadoop-2.2.0 >= 2.2.0
Requires: vcc-hive-0.12.0
# Hive 0.13 has not yet been tested with this version of Impala.
# Requires: vcc-hive-0.13.0
Requires: jre >= 1.7
BuildRequires: vcc-hadoop-%{hadoop_ver} >= 2.2.0
BuildRequires: vcc-hive-%{hive_ver} >= 0.12.0
BuildRequires: boost = 1.46.1
BuildRequires: llvm = 3.3
BuildRequires: cmake >= 2.6.4
BuildRequires: cyrus-sasl-devel >= 2.1.23
BuildRequires: libevent-devel >= 1.4.13
BuildRequires: bzip2-devel >= 1.0.5
BuildRequires: gcc >= 4.4.7
BuildRequires: glibc-devel >= 2.12
BuildRequires: glibc-headers >= 2.12
BuildRequires: cpp >= 4.4.7
BuildRequires: kernel-headers >= 2.6.32
BuildRequires: bison >= 2.4.1
BuildRequires: automake >= 1.11.1
BuildRequires: gcc-c++ >= 4.4.7
BuildRequires: openssl-devel >= 1.0.1e
BuildRequires: autoconf >= 2.63
BuildRequires: zlib-devel >= 1.2.3
BuildRequires: keyutils-libs-devel >= 1.4
BuildRequires: doxygen >= 1.6.1
BuildRequires: xz-lzma-compat >= 4.999.9
# BuildRequires: java-1.7.0-openjdk-devel >= 1.7.0.51
BuildRequires: jdk >= 1.7.0
BuildRequires: wget >= 1.11
BuildRequires: apache-maven >= 3.2.1
BuildRequires: python-setuptools >= 0.6.10
BuildRequires: python-devel >= 2.6.6
BuildRequires: svn
BuildRequires: git

# Apply all patches to fix CLASSPATH and java lib issues
# Patch1: %{_sourcedir}/patch.impala

Url: http://www.altiscale.com/

%description
%{pkg_name} is a repackaged impala distro that is compiled against Altiscale Hadoop 2.2.x. 
This package should work with Altiscale Hadoop. We choose v1.2.2 as base, and applied
a patch that doesn't have a tag on Git to fix a major Parquet bug from v.1.2.2 to v.1.2.3. 
This version works with Hive 0.12 and requires mysql and other component that works with Hive and HCatalog.
The patch includes both v1.2.2 to v1.2.3 and updating HADOOP_VERSION and HADOOP_CONF_DIR to 
point to vcc-hadoop files.

%prep
# copying files into BUILD/impala/ e.g. BUILD/impala/* 
# echo "ok - copying files from %{_sourcedir} to folder  %{_builddir}/%{service_name}"
# cp -r %{_sourcedir}/%{service_name} %{_builddir}/

%setup -q -n %{service_name}

# Use -p0 if you are building this without mock
# %patch1 -p0
# %patch1 -p1


%build
echo "ANT_HOME=$ANT_HOME"
echo "JAVA_HOME=$JAVA_HOME"
echo "MAVEN_HOME=$MAVEN_HOME"
echo "MAVEN_OPTS=$MAVEN_OPTS"
echo "M2_HOME=$M2_HOME"
echo "M2=$M2"

echo "build - impala core in %{_builddir}"
pushd `pwd`
cd %{_builddir}/%{service_name}/
export IMPALA_HOME=`pwd`
export HADOOP_VERSION=%{hadoop_ver}
export HIVE_VERSION=%{hive_ver}
. bin/impala-config.sh
source bin/impala-config.sh
env | grep "IMPALA.*VERSION"
cd thirdparty
# Patch this shell script, it has a bug
echo "ok - downloading 3rd party"
./download_thirdparty.sh
cd ..
pushd `pwd`
echo "IMPALA_HOME=$IMPALA_HOME"
cd "$IMPALA_HOME"
# Patch this from Debug to Release
# ./buildall.sh
# Skip all test, don't format mini cluster since we don't have one setup for testing
./buildall.sh -skiptests
popd

popd
echo "Build Completed successfully!"

%install
# manual cleanup for compatibility, and to be safe if the %clean isn't implemented
rm -rf %{buildroot}%{install_impala_dest}
# re-create installed dest folders
mkdir -p %{buildroot}%{install_impala_dest}
echo "compiled/built folder is (not the same as buildroot) RPM_BUILD_DIR = %{_builddir}"
echo "test installtion folder (aka buildroot) is RPM_BUILD_ROOT = %{buildroot}"
echo "test install impala dest = %{buildroot}/%{install_impala_dest}"
echo "test install impala label pkg_name = %{pkg_name}"
%{__mkdir} -p %{buildroot}%{install_impala_dest}/
# TBD: remove this when we figure out all the necessary files that needs to be installed
# cp -rp %{_builddir}/%{service_name} %{buildroot}%{install_impala_dest}

echo "man page dir = %{_mandir}"
echo "bin dir = %{_bindir}"
echo "java dir = %{_javadir}"
echo "data dir = %{_datadir}"

# Incremental fix on installed files
install -dm 755 %{buildroot}%{_bindir}
install -dm 755 %{buildroot}%{libdir}
install -dm 755 %{buildroot}%{libdir}/{sbin-debug,llvm-ir,lib,www}

install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/impalad %{buildroot}%{_bindir}/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/catalog/catalogd %{buildroot}%{_bindir}/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/statestore/statestored %{buildroot}%{_bindir}/

install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/test-loop.ir %{buildroot}%{libdir}/llvm-ir/test-loop.ir
install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/impala-no-sse.ll %{buildroot}%{libdir}/llvm-ir/impala-no-sse.ll
install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/impala-sse.ll %{buildroot}%{libdir}/llvm-ir/impala-sse.ll

install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/libfesupport.so %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/impalad %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/catalog/catalogd %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/util/libloggingsupport.so %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/statestore/statestored %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/session-expiry-test %{buildroot}%{libdir}/sbin-debug/

# Copy bootstrap doc
cp -rp %{_builddir}/%{service_name}/www/* %{buildroot}%{libdir}/www/

pushd %{_builddir}/%{service_name}/fe/target/dependency/
   for i in *.jar
   do
      install -p -m 644 "%{_builddir}/%{service_name}/fe/target/dependency/$i" %{buildroot}%{libdir}/lib/
   done
popd


%clean
echo "ok - cleaning up temporary files, deleting %{buildroot}%{install_impala_dest}"
rm -rf %{buildroot}%{install_impala_dest}

%files
%defattr(0755,root,root,0755)
# %{install_impala_dest}
%{_bindir}/*
%{libdir}/llvm-ir/
%{libdir}/lib/
%{libdir}/www/
%{libdir}/sbin-debug/

%post
#Install libhdfs and libhadoop to /usr/lib/impala/lib/
ln -s /opt/hadoop-%{hadoop_ver}/lib/native/libhadoop.so.1.0.0  %{libdir}/lib/libhadoop.so.1.0.0
ln -s /opt/hadoop-%{hadoop_ver}/lib/native/libhdfs.so.0.0.0  %{libdir}/lib/libhdfs.so.0.0.0

%postun
rm -f %{libdir}/lib/libhadoop.so.1.0.0
rm -f %{libdir}/lib/libhdfs.so.0.0.0

%changelog
* Wed May 28 2014 Andrew Lee 20140528
- Complete install section with all libs and binaries
* Tue May 13 2014 Andrew Lee 20140513
- Update BuildRequire tag to include missing dependencies libs
* Wed Apr 03 2014 Andrew Lee 20140403
- Initial Creation of spec file for Impala-v1.2.2-p0


