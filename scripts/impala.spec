%global impala_user         impala
%global impala_uid          411460044
%global impala_gid          411460016
%global libdir              /usr/lib/impala/
%global shell_libdir        /usr/lib/impala-shell/
%global vardir              %{_localstatedir}
%global confdir             %{_sysconfdir}

%define major_ver           IMPALA_VERSION
%define hadoop_ver          HADOOP_VERSION_REPLACE
%define hive_ver            HIVE_VERSION_REPLACE
%define service_name        alti-impala
%define company_prefix      altiscale
%define pkg_name            %{service_name}-%{major_ver}
%define install_impala_dest /opt/%{pkg_name}
%define build_release       BUILD_TIME

Name: %{service_name}-%{major_ver}
Summary: %{pkg_name} RPM Installer
Version: %{major_ver}
Release: %{build_release}%{?dist}
License: Copyright (C) 2014 Altiscale. All rights reserved.
Source: %{_sourcedir}/%{service_name}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{major_ver}-%{release}-root-%{service_name}
Requires: vcc-hadoop-%{hadoop_ver}
Requires: vcc-hive-%{hive_ver}
Requires: jdk >= 1.7
Requires: boost = 1.46.1
Requires: cyrus-sasl-devel >= 2.1.23
Requires: cyrus-sasl-gssapi >= 2.1.23
Requires: python-setuptools >= 0.6.10
Requires: /sbin/ldconfig
# For init.d script and chkconfig
Requires: redhat-lsb >= 4.0
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

%pre
# Soft creation for impala user if it doesn't exist. This behavior is idempotence to Chef deployment.
# Should be harmless. MAKE SURE UID and GID is correct FIRST!!!!!!
getent group %{impala_user} >/dev/null || groupadd -f -g %{impala_gid} -r %{impala_user}
if ! getent passwd %{impala_user} >/dev/null ; then
    if ! getent passwd %{impala_uid} >/dev/null ; then
      useradd -r -u %{impala_uid} -g %{impala_user} -c "Soft creation of user and group of impala for manual deployment" %{impala_user}
    else
      useradd -r -g %{impala_user} -c "Soft adding user impala to group impala for manual deployment" %{impala_user}
    fi
fi

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
rm -rf %{buildroot}%{_bindir}
rm -rf %{buildroot}%{libdir}
rm -rf %{buildroot}%{vardir}
rm -rf %{buildroot}%{confdir}
rm -rf %{buildroot}%{_libexecdir}
rm -rf %{buildroot}%{_defaultdocdir}

# re-create installed dest folders
echo "compiled/built folder is (not the same as buildroot) RPM_BUILD_DIR = %{_builddir}"
echo "test installtion folder (aka buildroot) is RPM_BUILD_ROOT = %{buildroot}"

echo "test install impala dest = %{buildroot}/%{_bindir}"
echo "test install impala dest = %{buildroot}/%{libdir}"
echo "test install impala dest = %{buildroot}/%{vardir}"
echo "test install impala dest = %{buildroot}/%{confdir}"
echo "test install impala dest = %{buildroot}/%{_libexecdir}"
echo "test install impala dest = %{buildroot}/%{_defaultdocdir}"
echo "test install impala label pkg_name = %{pkg_name}"

# cp -rp %{_builddir}/%{service_name} %{buildroot}%{install_impala_dest}
# TBD: remove this when we figure out all the necessary files that needs to be installed
# cp -rp %{_builddir}/%{service_name} %{buildroot}%{install_impala_dest}

echo "man page dir = %{_mandir}"
echo "bin dir = %{_bindir}"
echo "java dir = %{_javadir}"
echo "data dir = %{_datadir}"
echo "libexec dir = %{_libexecdir}"
echo "defaultdoc dir = %{_defaultdocdir}"

install -dm 755 %{buildroot}%{install_impala_dest}/bin/
install -dm 755 %{buildroot}%{install_impala_dest}/etc/rc.d/init.d/
cp -rp %{_builddir}/%{service_name}/bin/* %{buildroot}%{install_impala_dest}/bin/

# Incremental fix on installed files
install -dm 755 %{buildroot}%{_bindir}
install -dm 755 %{buildroot}%{libdir}
install -dm 755 %{buildroot}%{shell_libdir}/{ext-py,gen-py,lib}
install -dm 755 %{buildroot}%{vardir}
install -dm 755 %{buildroot}%{libdir}/{sbin-debug,llvm-ir,lib,www}
install -dm 755 %{buildroot}%{vardir}/{log,run,lib}
install -dm 755 %{buildroot}%{vardir}/log/impala
install -dm 755 %{buildroot}%{vardir}/run/impala
install -dm 755 %{buildroot}%{vardir}/lib/impala
install -dm 755 %{buildroot}%{confdir}/impala/conf.dist/
install -dm 755 %{buildroot}%{confdir}/default/
install -dm 755 %{buildroot}%{confdir}/security/limits.d/
install -dm 755 %{buildroot}%{confdir}/init.d/
# The following 2 folders only exist in 1.2.2 (1.2.4, and further version don't have these 2 anymore from bigtop)
install -dm 755 %{buildroot}%{_libexecdir}/
install -dm 755 %{buildroot}%{_defaultdocdir}/bigtop-utils-0.4+300/

install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/impalad %{buildroot}%{_bindir}/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/catalog/catalogd %{buildroot}%{_bindir}/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/statestore/statestored %{buildroot}%{_bindir}/

# Install impala-shell binaries and libs
install -p -m 755 %{_builddir}/%{service_name}/shell/build/impala-shell-1.2.2/impala-shell %{buildroot}%{_bindir}/
cp -rp %{_builddir}/%{service_name}/shell/build/impala-shell-1.2.2/ext-py/* %{buildroot}%{shell_libdir}/ext-py/
cp -rp %{_builddir}/%{service_name}/shell/build/impala-shell-1.2.2/gen-py/* %{buildroot}%{shell_libdir}/gen-py/
cp -rp %{_builddir}/%{service_name}/shell/build/impala-shell-1.2.2/lib/* %{buildroot}%{shell_libdir}/lib/
install -p -m 755  %{_builddir}/%{service_name}/shell/build/impala-shell-1.2.2/impala_shell.py %{buildroot}%{shell_libdir}/

install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/test-loop.ir %{buildroot}%{libdir}/llvm-ir/test-loop.ir
install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/impala-no-sse.ll %{buildroot}%{libdir}/llvm-ir/impala-no-sse.ll
install -p -m 755 %{_builddir}/%{service_name}/llvm-ir/impala-sse.ll %{buildroot}%{libdir}/llvm-ir/impala-sse.ll

# Commented out the follow 3 binaries since they are identical, if we have a debug build, we will need to use those with
# the symbols here instead of the release binaries.
# install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/impalad %{buildroot}%{libdir}/sbin-debug/
# install -p -m 755 %{_builddir}/%{service_name}/be/build/release/catalog/catalogd %{buildroot}%{libdir}/sbin-debug/
# install -p -m 755 %{_builddir}/%{service_name}/be/build/release/statestore/statestored %{buildroot}%{libdir}/sbin-debug/

install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/libfesupport.so %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/util/libloggingsupport.so %{buildroot}%{libdir}/sbin-debug/
install -p -m 755 %{_builddir}/%{service_name}/be/build/release/service/session-expiry-test %{buildroot}%{libdir}/sbin-debug/

# Copy bootstrap doc
cp -rp %{_builddir}/%{service_name}/www/* %{buildroot}%{libdir}/www/

# .so .a libraries
install -p -m 644 "%{_builddir}/%{service_name}/thirdparty/snappy-1.0.5/.libs/libsnappy.so.1.1.3" %{buildroot}%{libdir}/lib/

pushd %{_builddir}/%{service_name}/fe/target/dependency/
   install -p -m 644 "%{_builddir}/%{service_name}/fe/target/impala-frontend-0.1-SNAPSHOT.jar" %{buildroot}%{libdir}/lib/
   for i in *.jar
   do
      install -p -m 644 "%{_builddir}/%{service_name}/fe/target/dependency/$i" %{buildroot}%{libdir}/lib/
   done
popd

# Install system config and license
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/default/impala %{buildroot}%{confdir}/default/impala
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/default/bigtop-utils %{buildroot}%{confdir}/default/bigtop-utils
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/security/limits.d/impala.conf %{buildroot}%{confdir}/security/limits.d/impala.conf
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/rc.d/init.d/impala-server %{buildroot}%{install_impala_dest}%{confdir}/rc.d/init.d/impala-server
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/rc.d/init.d/impala-catalog %{buildroot}%{install_impala_dest}%{confdir}/rc.d/init.d/impala-catalog
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/rc.d/init.d/impala-state-store %{buildroot}%{install_impala_dest}%{confdir}/rc.d/init.d/impala-state-store
install -p -m 755 %{_builddir}/%{service_name}/%{confdir}/security/limits.d/impala.conf %{buildroot}%{confdir}/security/limits.d/impala.conf
install -p -m 755 %{_builddir}/%{service_name}/%{_libexecdir}/bigtop-detect-javahome %{buildroot}%{_libexecdir}/bigtop-detect-javahome
install -p -m 755 %{_builddir}/%{service_name}/%{_defaultdocdir}/bigtop-utils-0.4+300/LICENSE %{buildroot}%{_defaultdocdir}/bigtop-utils-0.4+300/LICENSE


%clean
# echo "ok - cleaning up temporary files, deleting %{buildroot}%{install_impala_dest}"
# rm -rf %{buildroot}%{install_impala_dest}
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{_bindir}"
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{libdir}"
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{vardir}"
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{confdir}"
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{_libexecdir}"
echo "ok - cleaning up temporary files, deleting %{buildroot}/%{_defaultdocdir}"
rm -rf %{buildroot}%{_bindir}
rm -rf %{buildroot}%{libdir}
rm -rf %{buildroot}%{vardir}
rm -rf %{buildroot}%{confdir}
rm -rf %{buildroot}%{_libexecdir}
rm -rf %{buildroot}%{_defaultdocdir}

%files
%defattr(0755,impala,impala,0755)
%doc %{_defaultdocdir}/bigtop-utils-0.4+300/LICENSE
%{install_impala_dest}/bin
%{install_impala_dest}%{confdir}
%{_bindir}/*
%{libdir}/llvm-ir/
%{libdir}/lib/
%{libdir}/www/
%{libdir}/sbin-debug/
%{shell_libdir}/*
%{shell_libdir}/ext-py/
%{shell_libdir}/gen-py/
%{shell_libdir}/lib/
%{confdir}/default/impala
%{confdir}/default/bigtop-utils
%{confdir}/security/limits.d/impala.conf
%{_libexecdir}/bigtop-detect-javahome
%dir %{vardir}/lib/impala
%dir %{vardir}/run/impala
%dir %{vardir}/log/impala
%dir %{confdir}/impala/conf.dist/

%post -p /sbin/ldconfig
#Install libhdfs and libhadoop to /usr/lib/impala/lib/
rm -f %{libdir}/lib/libhadoop.so.1.0.0
rm -f %{libdir}/lib/libhdfs.so.0.0.0
rm -f /opt/impala
rm -f %{libdir}/sbin-debug/impalad
rm -f %{libdir}/sbin-debug/catalogd
rm -f %{libdir}/sbin-debug/statestored
ln -s /opt/hadoop-%{hadoop_ver}/lib/native/libhadoop.so.1.0.0  %{libdir}/lib/libhadoop.so.1.0.0
ln -s /opt/hadoop-%{hadoop_ver}/lib/native/libhdfs.so.0.0.0  %{libdir}/lib/libhdfs.so.0.0.0
ln -s /opt/%{service_name}-%{major_ver} /opt/impala
ln -s %{_bindir}/impalad %{libdir}/sbin-debug/impalad
ln -s %{_bindir}/catalogd %{libdir}/sbin-debug/catalogd
ln -s %{_bindir}/statestored %{libdir}/sbin-debug/statestored

%postun -p /sbin/ldconfig
rm -f %{libdir}/lib/libhadoop.so.1.0.0
rm -f %{libdir}/lib/libhdfs.so.0.0.0
rm -f /opt/impala
rm -f %{libdir}/sbin-debug/impalad
rm -f %{libdir}/sbin-debug/catalogd
rm -f %{libdir}/sbin-debug/statestored

%changelog
* Mon Jun 2 2014 Andrew Lee 20140602
- update install and post macros to include more files and create links
* Fri May 30 2014 Andrew Lee 20140530
- Add sysconfig and license doc, add pre macro to soft create user and group
* Wed May 28 2014 Andrew Lee 20140528
- Complete install section with all libs and binaries
* Tue May 13 2014 Andrew Lee 20140513
- Update BuildRequire tag to include missing dependencies libs
* Wed Apr 03 2014 Andrew Lee 20140403
- Initial Creation of spec file for Impala-v1.2.2-p0


