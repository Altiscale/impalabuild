# This file is a submodule of ../build.sh.

mock_build_help()
{
    echo
    echo mock_build
    echo ----------
    echo "Performs the rpmbuild in the mock environment."
}

mock_build()
{
    if (($HELP)) ; then mock_build_help ; return ; fi

    if [ -z "$RPMBUILD" ] ; then
	echo "mock_build requires setup_rpmbuild"
	setup_rpmbuild
    fi
    if [ -z "$MOCK_DIR" ] ; then
	echo "mock_build requires setup_mock"
	setup_mock
    fi
    if [ ! -d "$MOCK_ROOT" ] ; then
	echo "mock_build requires init_mock"
	init_mock
    fi

    # TODO: resolve dependency on specific .src.rpm once SRPM name is in the environment
    if ( ! ls ${RPMBUILD}/SRPMS/*.src.rpm >& /dev/null ) ; then
	echo "mock_build requires build_srpm"
	build_srpm
    fi

    # run rpmbuild in the mock environment
    ${MOCK_CMD} --no-clean --rpmbuild_timeout=$MOCK_TIMEOUT --resultdir=${RPMBUILD}/RPMS/ --rebuild ${RPMBUILD}/SRPMS/*.src.rpm
}
