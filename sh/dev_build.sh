# This file is a submodule of ../build.sh.

dev_build_help()
{
    echo
    echo "dev_build (hybrid command)"
    echo "--------------------------"
    echo "Run the steps required for building on a development machine."
}

dev_build()
{
    if (($HELP)) ; then dev_build_help ; return ; fi

    version
    emulate_jenkins
    clean
    setup_environment
    setup_mock
}
