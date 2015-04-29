# This file is a submodule of ../build.sh.

init_mock_help()
{
    echo
    echo init_mock
    echo ----------
    echo "Initializes the mock chroot for building RPMs."
}

init_mock_cfg()
{
    # create the mock configuration
    cat >$MOCK_CFG_PATH <<EOF
# variables created by build ${BUILD_NUMBER}

config_opts['basedir'] = '${MOCK_DIR}/base'
config_opts['cache_topdir'] = '${MOCK_DIR}/cache'

config_opts['root'] = 'impala-epel-6-x86_64'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install @buildsys-build'
config_opts['dist'] = 'el6'  # only useful for --resultdir variable subst
config_opts['releasever'] = '6' # beware RHEL use 6Server or 6Client

config_opts['yum.conf'] = """
[main]
cachedir=/var/cache/yum
debuglevel=1
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=

# repos
EOF
    # copy repo configurations into the file
    for repofile in ${MOCK_REPOS} ; do
	echo >>$MOCK_CFG_PATH
	cat $repofile >>$MOCK_CFG_PATH
    done

    cat >>$MOCK_CFG_PATH <<EOF
"""
EOF
}

init_mock()
{
    if (($HELP)) ; then init_mock_help ; return ; fi

    if [ -z "$MOCK_DIR" ] ; then 
	echo "init_mock requires setup_mock"
	setup_mock
    fi

    # create directories specified in mock configuration
    mkdir -p ${MOCK_DIR}/base
    chgrp mock ${MOCK_DIR}/base
    chmod g+rws ${MOCK_DIR}/base
    mkdir -p ${MOCK_DIR}/cache
    chgrp mock ${MOCK_DIR}/cache
    chmod g+rws ${MOCK_DIR}/cache

    init_mock_cfg
    cp $MOCK_CFG_SRCDIR/site-defaults.cfg $MOCK_DIR
    cp /etc/mock/logging.ini $MOCK_DIR

    # initialize mock
    ${MOCK_CMD} --init

    # Note: If you need to do interactive debugging in the mock chroot, run:
    #   ${MOCK_CMD} --shell
    # Using --shell sets up the chroot so that it will actually work.
    # For example, it mounts the /proc file system.  If you don't mount the
    # mock file system, attempting to run java will generate an error that
    # looks like this:
    #   /usr/java/default/bin/java: error while loading shared libraries: libjli.so: cannot open shared object file: No such file or directory
    # It is possible to solve this issue by running "mount -t proc none /proc"
    # in the chroot, but it is better to enter the chroot with mock --shell.
}
