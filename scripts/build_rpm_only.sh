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

cdh_property_file="$curr_dir/cdh_version.properties"
GIT_HASH=""

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
  echo hello
  # Erase our track for any sensitive credentials if necessary
  #rm -f $WORKSPACE/rpmbuild/RPMS/noarch/alti-maven-settings*.rpm
  #rm -f $WORKSPACE/rpmbuild/RPMS/noarch/alti-maven-settings*.src.rpm
  #rm -f $WORKSPACE/rpmbuild/SRPMS/alti-maven-settings*.src.rpm
  #rm -rf $WORKSPACE/rpmbuild/SOURCES/alti-maven-settings*
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
  echo "ok - switching to impala branch $BRANCH_NAME and refetch the files"
  git checkout $BRANCH_NAME
  git fetch --all
  git pull
  set -a
  export GIT_HASH=$(git rev-parse HEAD)
  set +a
popd

# Generate cloudera properties file
echo -e "\n#Autogenerated build properties\nversion=$IMPALA_VERSION-SNAPSHOT\ngit.hash=${GIT_HASH}\ncloudera.hash=${GIT_HASH}\n\
cloudera.base-branch=$BRANCH_NAME\ncloudera.build-branch=cdh4-1.4\ncloudera.pkg.version=$IMPALA_VERSION\
\ncloudera.pkg.release=1.4+cdh4.5+0\ncloudera.pkg.name=impala\ncloudera.cdh.release=NA\ncloudera.build.time=$(date -u +%Y.%m.%d-%H:%M:%S%Z)" > "$cdh_property_file"

cat "$cdh_property_file"

echo "ok - tar zip source file, preparing for build/compile by rpmbuild"
mkdir -p $WORKSPACE/rpmbuild/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
cp -f "$impala_spec" $WORKSPACE/rpmbuild/SPECS/impala.spec
pushd $WORKSPACE
tar --exclude .git --exclude .gitignore -cf $WORKSPACE/rpmbuild/SOURCES/impala.tar impala
popd

pushd "$WORKSPACE/rpmbuild/SOURCES/"
tar -xf impala.tar
if [ -d alti-impala ] ; then
  rm -rf alti-impala
fi
mv impala alti-impala
rm -f alti-impala/$(basename $cdh_property_file)
cp "$cdh_property_file" alti-impala/
tar --exclude .git --exclude .gitignore -cpzf alti-impala.tar.gz alti-impala
stat alti-impala.tar.gz

if [ -f "$maven_settings" ] ; then
  mkdir -p  alti-maven-settings
  cp "$maven_settings" alti-maven-settings/
  tar -cvzf alti-maven-settings.tar.gz alti-maven-settings
  cp "$maven_settings_spec" $WORKSPACE/rpmbuild/SPECS/
fi
# 
# Explicitly define IMPALA_HOME here for build purpose
export IMPALA_HOME=$WORKSPACE/rpmbuild/BUILD/alti-impala
echo "ok - applying version number $IMPALA_VERSION and release number $BUILD_TIME, the pattern delimiter is / here"
sed -i "s/IMPALA_VERSION/$IMPALA_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/HADOOP_VERSION_REPLACE/$HADOOP_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/HIVE_VERSION_REPLACE/$HIVE_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_USER/$IMPALA_USER/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_GID/$IMPALA_GID/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/IMPALA_UID/$IMPALA_UID/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"
sed -i "s/BUILD_TIME/$BUILD_TIME/g" "$WORKSPACE/rpmbuild/SPECS/impala.spec"

rpmbuild -vvv -ba --define "_topdir $WORKSPACE/rpmbuild" --buildroot $WORKSPACE/rpmbuild/BUILDROOT/ $WORKSPACE/rpmbuild/SPECS/impala.spec
if [ $? -ne "0" ] ; then
  echo "fail - rpmbuild -ba RPM build failed"
  exit -96
fi

rpmbuild -vvv -bi --short-circuit --define "_topdir $WORKSPACE/rpmbuild" --buildroot $WORKSPACE/rpmbuild/BUILDROOT/ $WORKSPACE/rpmbuild/SPECS/impala.spec
if [ $? -ne "0" ] ; then
  echo "fail - rpmbuild -bi --short-circuit RPM build failed"
  exit -97
fi

exit 0












