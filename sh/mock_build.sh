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

    SRPM=${RPMBUILD}/SRPMS/alti-impala-${IMPALA_VERSION}-${BUILD_NUMBER}.src.rpm
    if ( ! ls $SRPM >& /dev/null ) ; then
	echo "mock_build requires build_srpm"
	build_srpm
    fi

    # run rpmbuild in the mock environment
    ${MOCK_CMD} \
	--no-clean \
	--define "impala_version ${IMPALA_VERSION}" \
	--define "buildnum ${BUILD_NUMBER}" \
	--define "impala_hadoop_version ${IMPALA_HADOOP_VERSION}" \
	--define "impala_hadoop_home ${IMPALA_HADOOP_HOME}" \
	--define "impala_hive_version ${IMPALA_HIVE_VERSION}" \
	--define "impala_hive_home ${IMPALA_HIVE_HOME}" \
	--rpmbuild_timeout=$MOCK_TIMEOUT \
	--resultdir=${RPMBUILD}/RPMS/ \
	--rebuild $SRPM
}
