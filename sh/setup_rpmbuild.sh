# This file is a submodule of ../build.sh.

setup_rpmbuild_help()
{
    echo
    echo setup_rpmbuild
    echo --------------
    echo "Sets up the rpmbuild tree."
}

setup_rpmbuild()
{
    if (($HELP)) ; then setup_rpmbuild_help ; return ; fi

    if [ -z "$BUILD_DIR" ] ; then echo "setup_rpmbuild requires BUILD_DIR" ; exit 1 ; fi

    : ${RPMBUILD:=${BUILD_DIR}/rpmbuild}
    : ${RPMBUILD_COMMAND:="rpmbuild -vvv --define '_topdir $RPMBUILD'"}

    mkdir -p ${RPMBUILD}/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
}
