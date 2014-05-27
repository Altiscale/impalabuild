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
if [ "x${HADOOP_HOME}" = "x" ] ; then
  export HADOOP_HOME=/opt/hadoop
fi
if [ "x${HADOOP_CONF_DIR}" = "x" ] ; then
  export HADOOP_CONF_DIR=/etc/hadoop
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
  export IMPALA_VERSION=v1.2.2
fi

# The build time here is par tof the release number
# It is monotonic increasing
BUILD_TIME=1
export BUILD_TIME

# Customize build OPTS for MVN
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"




