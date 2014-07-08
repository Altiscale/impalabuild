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
  export MAVEN_HOME=/opt/apache-maven
fi
if [ "x${M2_HOME}" = "x" ] ; then
  export M2_HOME=/opt/apache-maven
fi
if [ "x${M2}" = "x" ] ; then
  export M2=${M2_HOME}/bin
fi
if [ "x${MAVEN_OPTS}" = "x" ] ; then
  export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"
fi
if [ "x${SCALA_HOME}" = "x" ] ; then
  export SCALA_HOME=/opt/scala
fi
if [ "x${HADOOP_VERSION}" = "x" ] ; then
  export HADOOP_VERSION=2.2.0
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

export PATH=$PATH:$M2_HOME/bin:$SCALA_HOME/bin:$ANT_HOME/bin:$JAVA_HOME/bin

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
  export IMPALA_VERSION=1.3.1
fi

if [ "x${ALTISCALE_RELEASE}" = "x" ] ; then
  export ALTISCALE_RELEASE=2.0.0
else
  export ALTISCALE_RELEASE
fi

if [ "x${BRANCH_NAME}" = "x" ] ; then
  export BRANCH_NAME=altiscale-branch-1.3.1-cdh5
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




