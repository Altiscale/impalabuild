# This file is a submodule of ../build.sh.

# TODO: honor system pre-defined property/variable files from 
# /etc/hadoop/ and other /etc config for spark, hdfs, hadoop, etc
# Or not? This configuration should come from chef, not the RPM.

setup_environment_help()
{
    echo
    echo setup_environment
    echo -----------------
    echo "Set up the shell environment used by the build"
}

setup_environment()
{
    if (($HELP)) ; then setup_environment_help ; return ; fi

    if [ -z "$WORKSPACE" ] ; then
	echo "setup_environment requires emulate_jenkins"
	emulate_jenkins
    fi

    BUILD_DIR=${WORKSPACE}/build-${BUILD_NUMBER}

    # TODO: clean commented lines below, verify that all variables are used
    # IMPALA_GIT=${WORKSPACE}/${IMPALA_REPO}

    # default if not already in build environment
    export JAVA_HOME=${JAVA_HOME:=/usr/java/default}
    export ANT_HOME=${ANT_HOME:=/opt/apache-ant}
    export MAVEN_HOME=${MAVEN_HOME:=/usr/share/java/apache-maven}

    # Reset to empty value to fix Maven 3 problem
    export M2_HOME=
    export M2=${M2:=/usr/bin}

    export MAVEN_OPTS=${MAVEN_OPTS:="-Xmx2048m -XX:MaxPermSize=1024m"}
    export SCALA_HOME=${SCALA_HOME:=/opt/scala}
    export IMPALA_HADOOP_HOME=${HADOOP_HOME:=/opt/hadoop-${IMPALA_HADOOP_VERSION}}
    # export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:=/etc/hadoop-${ALTISCALE_HADOOP_VERSION}}
    export IMPALA_HIVE_HOME=${HIVE_HOME:=/opt/hive-${IMPALA_HIVE_VERSION}}
    # export HIVE_CONF_DIR=${HIVE_CONF_DIR:=/etc/hive-${ALTISCALE_HIVE_VERSION}}

    export PATH=$PATH:$M2:$SCALA_HOME/bin:$ANT_HOME/bin:$JAVA_HOME/bin

    # Define defau;t spark uid:gid and build version
    # WARNING: the IMPALA_VERSION branch name does not align with the Git branch name branch-0.8 / trunk
    # export IMPALA_USER=${IMPALA_USER:=impala}
    # export IMPALA_GID=${IMPALA_GID:=411460016}
    # export IMPALA_UID=${IMPALA_UID:=411460044}

    # export IMPALA_VERSION=${IMPALA_VERSION:=2.1.2.h13}

    # export ALTISCALE_RELEASE=${ALTISCALE_RELEASE:=3.0.0}
    export BUILD_TIMEOUT=${BUILD_TIMEOUT:=14400}
}
