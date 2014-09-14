#!/bin/bash

# TBD: honor system pre-defined property/variable files from 
# /etc/hadoop/ and other /etc config for spark, hdfs, hadoop, etc

if [ "x${JAVA_HOME}" = "x" ] ; then
  export JAVA_HOME=/usr/java/default
fi
if [ "x${ANT_HOME}" = "x" ] ; then
  export ANT_HOME=/opt/apache-ant
fi
if [ "x${MAVEN_HOME}" = "x" ] ; then
  export MAVEN_HOME=/usr/share/java/apache-maven
fi

# Reset to empty value to fix Maven 3 problem
export M2_HOME=

if [ "x${M2}" = "x" ] ; then
  export M2=/usr/bin
fi
if [ "x${MAVEN_OPTS}" = "x" ] ; then
  export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"
fi
if [ "x${SCALA_HOME}" = "x" ] ; then
  export SCALA_HOME=/opt/scala
fi
if [ "x${HADOOP_VERSION}" = "x" ] ; then
  export HADOOP_VERSION=2.4.1
fi
if [ "x${HIVE_VERSION}" = "x" ] ; then
  export HIVE_VERSION=0.12.0
fi
if [ "x${HADOOP_HOME}" = "x" ] ; then
  export HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
fi
if [ "x${HADOOP_CONF_DIR}" = "x" ] ; then
  export HADOOP_CONF_DIR=/etc/hadoop-${HADOOP_VERSION}
fi
if [ "x${HIVE_HOME}" = "x" ] ; then
  export HIVE_HOME=/opt/hive-${HIVE_VERSION}
fi
if [ "x${HIVE_CONF_DIR}" = "x" ] ; then
  export HIVE_CONF_DIR=/etc/hive-${HIVE_VERSION}
fi

echo "ok - Jenkins env HADOOP_VERSION=$HADOOP_VERSION"
echo "ok - Jenkins env HIVE_VERSION=$HIVE_VERSION"

export PATH=$PATH:$M2:$SCALA_HOME/bin:$ANT_HOME/bin:$JAVA_HOME/bin

# Define defau;t spark uid:gid and build version
# WARNING: the IMPALA_VERSION branch name does not align with the Git branch name branch-0.8 / trunk
if [ "x${IMPALA_USER}" = "x" ] ; then
  export IMPALA_USER=impala
fi
if [ "x${IMPALA_GID}" = "x" ] ; then
  export IMPALA_GID=411460016
fi
if [ "x${IMPALA_UID}" = "x" ] ; then
  export IMPALA_UID=411460044
fi
if [ "x${IMPALA_VERSION}" = "x" ] ; then
  if [ "x${HIVE_VERSION}" = "x0.12.0" ] ; then
    export IMPALA_VERSION=1.4-cdh4-hive12
  elif [ "x${HIVE_VERSION}" = "x0.13.0" ] ; then
    export IMPALA_VERSION=1.4-cdh4-hive13
  elif [ "x${HIVE_VERSION}" = "x0.13.1" ] ; then
    export IMPALA_VERSION=1.4-cdh4-hive13
  else
    echo "error - can't recognize HIVE_VERSION=$HIVE_VERSION"
  fi
fi

if [ "x${ALTISCALE_RELEASE}" = "x" ] ; then
  export ALTISCALE_RELEASE=3.0.0
else
  export ALTISCALE_RELEASE
fi

if [ "x${BRANCH_NAME}" = "x" ] ; then
  export BRANCH_NAME=altiscale-branch-1.4-cdh4
fi

if [ "x${BUILD_TIMEOUT}" = "x" ] ; then
  export BUILD_TIMEOUT=14400
fi

# The build time here is part of the release number
# It is monotonic increasing
BUILD_TIME=$(date +%Y%m%d%H%M)
export BUILD_TIME

# Customize build OPTS for MVN
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"




