#!/bin/bash

curr_dir=`dirname $0`
curr_dir=`cd $curr_dir; pwd`

setup_host="$curr_dir/setup_host.sh"
impala_spec="$curr_dir/impala.spec"
impala_zip_file="$WORKSPACE/v1.2.2.zip"
mock_cfg="$curr_dir/altiscale-impala-centos-6-x86_64.cfg"
mock_cfg_name=$(basename "$mock_cfg")
mock_cfg_runtime=`echo $mock_cfg_name | sed "s/.cfg/.runtime.cfg/"`

if [ -f "$curr_dir/setup_env.sh" ]; then
  source "$curr_dir/setup_env.sh"
fi

if [ "x${WORKSPACE}" = "x" ] ; then
  WORKSPACE="$curr_dir/../"
  impala_zip_file="$WORKSPACE/v1.2.2.zip"
fi

# Perform sanity check
if [ ! -f "$curr_dir/setup_host.sh" ]; then
  echo "warn - $setup_host does not exist, we may not need this if all the libs and RPMs are pre-installed"
fi

if [ ! -e "$impala_spec" ] ; then
  echo "fail - missing $impala_spec file, can't continue, exiting"
  exit -9
fi

# Install boost on the fly since we need version 1.42+
# Move this to a RPM and just install it, this takes ~15-20 minutes everytime.

env | sort
# should switch to WORKSPACE, current folder will be in WORKSPACE/impala due to 
# hadoop_ecosystem_component_build.rb => this script will change directory into your submodule dir
# WORKSPACE is the default path when jenkin launches e.g. /mnt/ebs1/jenkins/workspace/impala_build_test-alee
# If not, you will be in the $WORKSPACE/impala folder already, just go ahead and work on the submodule
# The path in the following is all relative, if the parent jenkin config is changed, things may break here.
pushd `pwd`
cd $WORKSPACE

# Manual fix Git URL issue in submodule, safety net, just in case the git scheme doesn't work
# sed -i 's/git\@github.com:Altiscale\/impala.git/https:\/\/github.com\/Altiscale\/impala.git/g' .gitmodules
# sed -i 's/git\@github.com:Altiscale\/impala.git/https:\/\/github.com\/Altiscale\/impala.git/g' .git/config
echo "ok - switching to impala-0.8 and refetch the files"
if [ -f "$impala_zip_file" ] ; then
  fhash=$(md5sum "$impala_zip_file" | cut -d" " -f1)
  if [ "x${fhash}" = "x9cacd6941f53cbaf18d2eb2e8039ae23" ] ; then
    echo "ok - md5 hash 9cacd6941f53cbaf18d2eb2e8039ae23 matched, file is the same, no need to re-download again, use current one on disk"
  else
    echo "warn - previous file hash $fhash <> 9cacd6941f53cbaf18d2eb2e8039ae23 , does not match , deleting and re-download again"
    echo "ok - deleting previous stale/corrupted file $WORKSPACE/v1.2.2.zip"
    stat "$impala_zip_file"
    rm -f "$impala_zip_file"
    wget --output-document=$impala_zip_file "https://github.com/Altiscale/Impala/archive/v1.2.2.zip"
  fi
else
  echo "ok - download impala source code fresh v1.2.2"
  wget --output-document=$impala_zip_file "https://github.com/Altiscale/Impala/archive/v1.2.2.zip"
fi

stat $impala_zip_file
unzip -t $impala_zip_file

unzip -o $impala_zip_file > /dev/null
if [ -d "$WORKSPACE/impala" ] ; then
  echo "ok - deleting folder $WORKSPACE/impala"
  stat "$WORKSPACE/impala"
  rm -rf "$WORKSPACE/impala"
fi
mv $WORKSPACE/Impala-* $WORKSPACE/impala
popd

echo "ok - tar zip source file, preparing for build/compile by rpmbuild"
pushd `pwd`
# impala is located at $WORKSPACE/impala
cd $WORKSPACE
# tar cvzf $WORKSPACE/impala.tar.gz impala
popd

# Looks like this is not installed on all machines
# rpmdev-setuptree
mkdir -p $WORKSPACE/rpmbuild/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
cp "$impala_spec" $WORKSPACE/rpmbuild/SPECS/impala.spec
cp -r $WORKSPACE/impala $WORKSPACE/rpmbuild/SOURCES/alti-impala
pushd "$WORKSPACE/rpmbuild/SOURCES/"
tar -czf alti-impala.tar.gz alti-impala
stat alti-impala.tar.gz
popd
cp $WORKSPACE/patches/* $WORKSPACE/rpmbuild/SOURCES/
# Explicitly define IMPALA_HOME here for build purpose
export IMPALA_HOME=$WORKSPACE/rpmbuild/BUILD/alti-impala
echo "ok - applying version number $IMPALA_VERSION and release number $BUILD_TIME, the pattern delimiter is / here"
sed -i "s/IMPALA_VERSION/$IMPALA_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_USER/$IMPALA_USER/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_GID/$IMPALA_GID/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_UID/$IMPALA_UID/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/BUILD_TIME/$BUILD_TIME/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"

rpmbuild -vvv -bs $WORKSPACE/rpmbuild/SPECS/impala.spec \
              --define "_topdir $WORKSPACE/rpmbuild" \
              --buildroot $WORKSPACE/rpmbuild/BUILDROOT/

if [ $? -ne "0" ] ; then
  echo "fail - rpmbuild SRPM build failed"
  exit -8
fi

stat "$WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm"
rpm -ivvv "$WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm"

echo "ok - applying $WORKSPACE for the new BASEDIR for mock, pattern delimiter here should be :"
# the path includeds /, so we need a diff pattern delimiter

mkdir -p "$WORKSPACE/var/lib/mock"
chmod 2755 "$WORKSPACE/var/lib/mock"
mkdir -p "$WORKSPACE/var/cache/mock"
chmod 2755 "$WORKSPACE/var/cache/mock"
sed "s:BASEDIR:$WORKSPACE:g" "$mock_cfg" > "$mock_cfg_runtime"
echo "ok - applying mock config $mock_cfg_runtime"
cat "$mock_cfg_runtime"
mock -vvv --configdir=$curr_dir -r altiscale-impala-centos-6-x86_64.runtime --resultdir=$WORKSPACE/rpmbuild/RPMS/ --rebuild $WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm

if [ $? -ne "0" ] ; then
  echo "fail - mock RPM build failed"
  exit -9
fi
  
echo "ok - build Completed successfully!"

exit 0












