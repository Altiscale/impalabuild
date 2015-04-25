# This file is a submodule of ../build.sh.

COMMAND_help()
{
    echo
    echo COMMAND
    echo -------
    echo "Documentation about this COMMAND."
}

COMMAND()
{
    if (($HELP)) ; then COMMAND_help ; return ; fi
}
