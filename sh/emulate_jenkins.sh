# This file is a submodule of ../build.sh.

emulate_jenkins_help()
{
   echo 
   echo emulate_jenkins
   echo ---------------
   echo "Sets up the shell environment to emulate the job-specific environment"
   echo "on jenkins.  Override these variables in the environment of this script:"
   echo "  GIT_USER = the git user to use for fetching the source"
   echo "  GIT_ORG = the git organization to use for fetching the source"
   echo "  IMPALA_REPO = the git repo name to use for fetching the source"
}

emulate_jenkins_git()
{
    pushd $WORKSPACE

    if [ ! -d $IMPALA_REPO ] ; then
	git clone ${GIT_URL}
    fi
    cd $IMPALA_REPO
    git fetch
    git checkout $GIT_BRANCH
    git pull

    popd
}

emulate_jenkins()
{
    if (($HELP)) ; then emulate_jenkins_help ; return ; fi
    
    # BASEDIR should typically use local, fast storage
    # Should have the same default as in install_build_framework
    : ${BASEDIR:=/mnt/ssdb/$USER}

    if [ ! -d "$BASEDIR" ] ; then
	echo "emulate_jenkins requires emulate_chef"
	emulate_chef
    fi

    # standard jenkins variables
    export WORKSPACE=${WORKSPACE:=${BASEDIR}/impalabuild}
    export BUILD_NUMBER=${BUILD_NUMBER:=$(date -u +%Y%m%dT%H%M%SZ)}
    
    mkdir -p $WORKSPACE

    # variables expected for this jenkins job
    export GIT_BRANCH=${GIT_BRANCH:=altiscale-branch-cdh5-2.1.2_5.3.2}
    export IMPALA_RELEASE=${IMPALA_RELEASE:=impala-2.1.2-cdh5.3.2}

    # emulate the git pull that jenkins will perform
    : ${GIT_USER:=git@github.com}
    : ${GIT_ORG:=Altiscale}
    : ${IMPALA_REPO:=Impala}
    GIT_URL=${GIT_USER}:${GIT_ORG}/${IMPALA_REPO}.git
    emulate_jenkins_git
}