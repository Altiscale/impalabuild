# This file is a submodule of ../build.sh.

build_srpm_help()
{
    echo
    echo build_srpm
    echo ----------
    echo "Builds the SRPM (source RPM) from the spec file and the"
    echo "source from github."
}

build_srpm()
{
    if (($HELP)) ; then build_srpm_help ; return ; fi

    if [ -z "$RPMBUILD" ] ; then
	echo "build_srpm requires setup_rpmbuild"
	setup_rpmbuild
    fi

    # copy the spec file into place
    : ${SPEC_PATH:=${APPDIR}/spec/impala.spec}
    cp ${SPEC_PATH} ${RPMBUILD}/SPECS/
    cp ${APPDIR}/src/* ${RPMBUILD}/SOURCES/

    # copy the source into place
    pushd ${WORKSPACE}
    tar --exclude .git --exclude .gitignore -czf ${RPMBUILD}/SOURCES/${IMPALA_RELEASE}.tar.gz ${IMPALA_RELEASE}
    popd

    # build the source rpm
    rpmbuild \
	-vvv \
	-bs \
	--define "_topdir $RPMBUILD" \
	--define "buildnum $BUILD_NUMBER" \
	${RPMBUILD}/SPECS/impala.spec
}
