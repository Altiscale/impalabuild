# This file is a submodule of ../build.sh.

steps=(
    version
    emulate_jenkins
    clean
    setup_environment
    setup_rpmbuild
    build_srpm
    setup_mock
    init_mock
    mock_build
)

dev_build_help()
{
    echo
    echo "dev_build (hybrid command)"
    echo "--------------------------"
    echo "Run the following steps required for development machine build:"
    for step in ${steps[@]} ; do
	echo "  $step"
    done
}

dev_build()
{
    if (($HELP)) ; then dev_build_help ; return ; fi

    for step in ${steps[@]} ; do
	echo "dev_build: running $step"
	$step
    done
}
