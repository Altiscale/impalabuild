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

    if [ -z "$WORKSPACE" ] ; then echo "clean requires WORKSPACE" ; exit 1 ; fi

    for mockdir in ${WORKSPACE}/build-*/mock ; do
	mock --configdir=$mockdir -r mock --clean
    done

    rm -rf ${WORKSPACE}/build-*
}
