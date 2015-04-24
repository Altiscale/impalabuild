# This file is a submodule of ../build.sh.

setup_rpmbuild_help()
{
    echo
    echo setup_rpmbuild
    echo --------------
    echo "Sets up the rpmbuild tree."
}

setup_rpmbuid()
{
    if (($HELP)) ; then setup_rpmbuild_help ; return ; fi
}
