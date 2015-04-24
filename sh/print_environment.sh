# This file is a submodule of ../build.sh.

print_environment_help()
{
    echo
    echo print_environment
    echo -----------------
    echo "Prints the shell environment used by the build"
}

print_environment()
{
    if (($HELP)) ; then print_environment_help ; return ; fi

    # TODO: print specific variables to avoid printing secrets by mistake
    env | sort
}
