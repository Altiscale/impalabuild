# This file is a submodule of ../build.sh.

command_help()
{
    echo
    echo command
    echo -------
    echo "Documentation about this command."
}

command()
{
    if (($HELP)) ; then command_help ; return ; fi
}
