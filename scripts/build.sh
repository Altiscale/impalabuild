#!/bin/bash

curr_dir=`dirname $0`
curr_dir=`cd $curr_dir; pwd`

impala_spec="$curr_dir/impala.spec"

mock_cfg="$curr_dir/altiscale-impala-centos-6-x86_64.cfg"
mock_cfg_name=$(basename "$mock_cfg")
mock_cfg_runtime=`echo $mock_cfg_name | sed "s/.cfg/.runtime.cfg/"`
build_timeout=14400

maven_settings="$HOME/.m2/settings.xml"
maven_settings_spec="$curr_dir/alti-maven-settings.spec"

if [ -f "$curr_dir/setup_env.sh" ]; then
  set -a
  # source "$curr_dir/setup_env.sh"
  . "$curr_dir/setup_env.sh"
  set +a
fi

if [ "x${BUILD_TIMEOUT}" = "x" ] ; then
  build_timeout=14400
else
  build_timeout=$BUILD_TIMEOUT
fi

if [ "x${WORKSPACE}" = "x" ] ; then
  WORKSPACE="$curr_dir/../"
fi

if [ ! -f "$maven_settings" ]; then
  echo "fatal - $maven_settings DOES NOT EXIST!!!! YOU MAY PULLING IN UNTRUSTED artifact and BREACH SECURITY!!!!!!"
  exit -9
fi

if [ ! -e "$impala_spec" ] ; then
  echo "fail - missing $impala_spec file, can't continue, exiting"
  exit -9
fi

cleanup_secrets()
{
  # Erase our track for any sensitive credentials if necessary
  rm -f $WORKSPACE/rpmbuild/RPMS/noarch/alti-maven-settings*.rpm
  rm -f $WORKSPACE/rpmbuild/RPMS/noarch/alti-maven-settings*.src.rpm
  rm -f $WORKSPACE/rpmbuild/SRPMS/alti-maven-settings*.src.rpm
  rm -rf $WORKSPACE/rpmbuild/SOURCES/alti-maven-settings*
}

env | sort
# should switch to WORKSPACE, current folder will be in WORKSPACE/impala due to 
# hadoop_ecosystem_component_build.rb => this script will change directory into your submodule dir
# WORKSPACE is the default path when jenkin launches e.g. /mnt/ebs1/jenkins/workspace/impala_build_test-alee
# If not, you will be in the $WORKSPACE/impala folder already, just go ahead and work on the submodule
# The path in the following is all relative, if the parent jenkin config is changed, things may break here.
pushd `pwd`
cd $WORKSPACE/impala
if [ "x${BRANCH_NAME}" = "x" ] ; then
  echo "error - BRANCH_NAME is not defined. Please specify the BRANCH_NAME explicitly. Exiting!"
  exit -9
fi
  echo "ok - switching to impaala branch $BRANCH_NAME and refetch the files"
  git checkout $BRANCH_NAME
  git fetch --all
  git pull
popd

echo "ok - tar zip source file, preparing for build/compile by rpmbuild"

# 
mkdir -p $WORKSPACE/rpmbuild/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
cp "$impala_spec" $WORKSPACE/rpmbuild/SPECS/impala.spec
pushd $WORKSPACE
tar --exclude .git --exclude .gitignore -cf $WORKSPACE/rpmbuild/SOURCES/impala.tar impala
popd

pushd "$WORKSPACE/rpmbuild/SOURCES/"
tar -xf impala.tar
if [ -d alti-impala ] ; then
  rm -rf alti-impala
fi
mv impala alti-impala
tar --exclude .git --exclude .gitignore -cpzf alti-impala.tar.gz alti-impala
stat alti-impala.tar.gz

if [ -f "$maven_settings" ] ; then
  mkdir -p  alti-maven-settings
  cp "$maven_settings" alti-maven-settings/
  tar -cvzf alti-maven-settings.tar.gz alti-maven-settings
  cp "$maven_settings_spec" $WORKSPACE/rpmbuild/SPECS/
fi

# cp $WORKSPACE/patches/* $WORKSPACE/rpmbuild/SOURCES/

popd

# Build alti-maven-settings RPM separately so it doesn't get exposed to spark's SRPM or any external trace
rpmbuild -vv -ba $WORKSPACE/rpmbuild/SPECS/alti-maven-settings.spec --define "_topdir $WORKSPACE/rpmbuild" --buildroot $WORKSPACE/rpmbuild/BUILDROOT/
if [ $? -ne "0" ] ; then
  echo "fail - alti-maven-settings SRPM build failed"
  cleanup_secrets
  exit -95
fi


# Explicitly define IMPALA_HOME here for build purpose
export IMPALA_HOME=$WORKSPACE/rpmbuild/BUILD/alti-impala
echo "ok - applying version number $IMPALA_VERSION and release number $BUILD_TIME, the pattern delimiter is / here"
sed -i "s/IMPALA_VERSION/$IMPALA_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/HADOOP_VERSION_REPLACE/$HADOOP_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/HIVE_VERSION_REPLACE/$HIVE_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/BUILD_TIME/$BUILD_TIME/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"

rpmbuild -vvv -bs $WORKSPACE/rpmbuild/SPECS/impala.spec \
              --define "_topdir $WORKSPACE/rpmbuild" \
              --buildroot $WORKSPACE/rpmbuild/BUILDROOT/

if [ $? -ne "0" ] ; then
  echo "fail - rpmbuild SRPM build failed"
  cleanup_secrets
  exit -96
fi

stat "$WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm"
rpm -ivvv "$WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm"

echo "ok - applying $WORKSPACE for the new BASEDIR for mock, pattern delimiter here should be :"
# the path includeds /, so we need a diff pattern delimiter

mkdir -p "$WORKSPACE/var/lib/mock"
chmod 2755 "$WORKSPACE/var/lib/mock"
mkdir -p "$WORKSPACE/var/cache/mock"
chmod 2755 "$WORKSPACE/var/cache/mock"
sed "s:BASEDIR:$WORKSPACE:g" "$mock_cfg" > "$curr_dir/$mock_cfg_runtime"
sed -i "s:IMPALA_VERSION:$IMPALA_VERSION:g" "$curr_dir/$mock_cfg_runtime"
echo "ok - applying mock config $curr_dir/$mock_cfg_runtime"
cat "$curr_dir/$mock_cfg_runtime"
mock -vvv --configdir=$curr_dir -r altiscale-impala-centos-6-x86_64.runtime --resultdir=$WORKSPACE/rpmbuild/RPMS/ --rebuild $WORKSPACE/rpmbuild/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_TIME}.el6.src.rpm

if [ $? -ne "0" ] ; then
  echo "fail - mock RPM build failed"
  cleanup_secrets
  mock --clean
  mock --scrub=all
  exit -97
fi

# Delete all src.rpm in the RPMS folder since this is redundant and copied by the mock process
rm -f $WORKSPACE/rpmbuild/RPMS/*.src.rpm  
mock --clean
mock --scrub=all

echo "ok - build Completed successfully!"

cleanup_secrets

exit 0












