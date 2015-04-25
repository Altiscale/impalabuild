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

    if [ -z "$RPMBUILD" ] ; then echo "build_srpm requires RPMBUILD" ; exit 1 ; fi

    # copy the spec file into place
    : ${SPEC_PATH:=${APPDIR}/spec/impala.spec}
    cp ${SPEC_PATH} ${RPMBUILD}/SPECS/

    # copy the source into place
    ( cd ${IMPALA_GIT} ; tar --exclude .git --exclude .gitignore -cf - . ) | ( cd $WORKSPACE/rpmbuild/SOURCES/ ; tar xf - )

    # build the source rpm
    ${RPMBUILD_COMMAND} -bs ${RPMBUILD}/SPECS/impala.spec
}
