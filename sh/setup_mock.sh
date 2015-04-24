# This file is a submodule of ../build.sh.

setup_mock_help()
{
    echo
    echo setup_mock
    echo ----------
    echo "Sets up the mock environment for building RPMs."
    echo "For more information about Mock, see:"
    echo "  https://fedoraproject.org/wiki/Projects/Mock"
}

setup_mock()
{
    if (($HELP)) ; then setup_mock_help ; return ; fi

    : ${MOCK_CFG_SRCDIR:=${APPDIR}/mock}
    : ${MOCK_CFG_SRC:=${MOCK_CFG_SRCDIR}/altiscale-impala-centos-6-x86_64.cfg}
    : ${MOCK_DIR:=${BUILD_DIR}/mock}
    : ${MOCK_CFG:="mock"}
    : ${MOCK_CFG_PATH:=${MOCK_DIR}/${MOCK_CFG}.cfg}
    : ${MOCK_VERBOSE:="-vvv"}
    : ${MOCK_CMD:="mock $MOCK_VERBOSE --configdir=${MOCK_DIR} -r ${MOCK_CFG}"}

    # create directories specified in mock configuration
    mkdir -p ${MOCK_DIR}/base
    chgrp mock ${MOCK_DIR}/base
    chmod g+rws ${MOCK_DIR}/base
    mkdir -p ${MOCK_DIR}/cache
    chgrp mock ${MOCK_DIR}/cache
    chmod g+rws ${MOCK_DIR}/cache

    # create the mock configuration
    cat >$MOCK_CFG_PATH <<EOF
# variables created by build #{BUILDNUM}

config_opts['basedir'] = '${MOCK_DIR}/base'
config_opts['cache_topdir'] = '${MOCK_DIR}/cache'

# variables from $MOCK_CFG_SRC
EOF
    cat $MOCK_CFG_SRC >>$MOCK_CFG_PATH
    cp $MOCK_CFG_SRCDIR/site-defaults.cfg $MOCK_DIR
    cp /etc/mock/logging.ini $MOCK_DIR


    # initialize mock
    ${MOCK_CMD} --init
}
