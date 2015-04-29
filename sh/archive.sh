# This file is a submodule of ../build.sh.

archive_help()
{
    echo
    echo archive
    echo -------
    echo "Archives the artifacts of mock_build.  On a jenkins system,"
    echo "this action would typically be peformed by a post-build step."
}

archive()
{
    if (($HELP)) ; then archive_help ; return ; fi

    if [ -z "$RPMBUILD" ] ; then
	echo "archive requires setup_rpmbuild"
	setup_rpmbuild
    fi
    if ( ! ls ${RPMBUILD}/RPMS/* >& /dev/null ) ; then
	echo "archive requires mock_build"
	mock_build
    fi

    : ${ARCHIVE_DIR:=~/artifacts/build-${BUILD_NUMBER}}

    # create the archive directory
    mkdir -p ${ARCHIVE_DIR}/RPMS
    cp -p ${RPMBUILD}/RPMS/*  ${ARCHIVE_DIR}/RPMS
    mkdir -p ${ARCHIVE_DIR}/SRPMS
    cp -p ${RPMBUILD}/SRPMS/* ${ARCHIVE_DIR}/SRPMS
}
