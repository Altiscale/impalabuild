# This file is a submodule of ../build.sh.

clean_help()
{
    echo
    echo clean
    echo -------
    echo "Removes artifacts from previous builds."
}

clean()
{
    if (($HELP)) ; then clean_help ; return ; fi

    rm -rf ${WORKSPACE}/build-*
}
