# This file is a submodule of ../build.sh.

setup_mock_help()
{
    echo
    echo setup_mock
    echo ----------
    echo "Sets up the mock environment variables."
    echo "Run init_mock to build the mock environment using"
    echo "the variables from this script."
    echo "For more information about Mock, see:"
    echo "  https://fedoraproject.org/wiki/Projects/Mock"
}

setup_mock()
{
    if (($HELP)) ; then setup_mock_help ; return ; fi

    if [ -z "$BUILD_DIR" ] ; then
	echo "setup_mock requires setup_environment"
	setup_environment
    fi

    : ${MOCK_CFG_SRCDIR:=${APPDIR}/mock}
    : ${MOCK_CFG_SRC:=${MOCK_CFG_SRCDIR}/altiscale-impala-centos-6-x86_64.cfg}
    : ${MOCK_DIR:=${BUILD_DIR}/mock}
    : ${MOCK_ROOT:=${MOCK_DIR}/base/impala-epel-6-x86_64/root}
    : ${MOCK_CFG:="mock"}
    : ${MOCK_CFG_PATH:=${MOCK_DIR}/${MOCK_CFG}.cfg}
    : ${MOCK_VERBOSE:="-vvv"}
    : ${MOCK_TIMEOUT:="14400"}
    : ${MOCK_CMD:="mock $MOCK_VERBOSE --configdir=${MOCK_DIR} -r ${MOCK_CFG}"}

    # yum repositories: Default to the same repositories available on the host.
    # Override MOCK_REPOS with a space-separated set of files to be more restrictive
    # or to specify a different set of repositories.

    : ${MOCK_REPOS:=`grep -l enabled=1 /etc/yum.repos.d/*.repo`}
}
