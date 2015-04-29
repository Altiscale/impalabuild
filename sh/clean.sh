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

    if [ -z "$WORKSPACE" ] ; then
	echo "clean requires emulate_jenkins"
	emulate_jenkins
    fi

    if ( ls ${WORKSPACE}/build-*/mock >& /dev/null ) ; then
	for mockdir in ${WORKSPACE}/build-*/mock ; do
	    if [ -f $mockdir/mock.cfg ] && [ -f $mockdir/site-defaults.cfg ] ; then
		mock --configdir=$mockdir -r mock --clean
	    fi
	done
    fi

    rm -rf ${WORKSPACE}/build-*
}
