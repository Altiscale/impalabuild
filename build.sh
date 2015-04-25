#!/bin/bash -e

# basic information about this script
APPNAME=$0
APPDIR=`dirname $APPNAME`
VERSION="0.1"

usage()
{
    echo "usage: $APPNAME [commands]"
    echo " individual commands:"
    echo "  help [commands] - print this message or information about commands"
    echo "  version - print version information"
    echo "  install_build_framework - one time set-up (requires sudo)"
    echo "  emulate_jenkins - set up the environment to emulate a jenkins job"
    echo "  setup_environment - set up the shell environment"
    echo "  print_environment - print the shell environment"
    echo "  setup_mock - set up the mock environment"
    echo "  clean - remove artifacts from previous builds"
    echo
    echo " hybrid commands:"
    echo "  dev_build - run all of the steps for a development build"
    echo "  jenkins_build - run all of the steps for a build on jenkins"
}

version()
{
    echo "$APPNAME: Altiscale Impala Build Script Version $VERSION"
}

# include submodules
for submodule in $APPDIR/sh/*.sh ; do
. $submodule
done

# emit usage if there are no arguments or just a request for help
case $# in
    (0) usage ; exit 1 ;;
    (1) if [ "$1" == "help" ] ; then usage ; exit 1 ; fi ;;
esac

# help as any other argument turns on help mode
HELP=0
for arg in $* ; do
    if [ "$arg" == "help" ] ; then HELP=1 ; fi
done

# show all commands if not running in help mode
if !(($HELP)) ; then set -x ; fi

# each argument must be a command that this script knows how to run
for arg in $* ; do 
    # process all commands
    case $arg in
	( "help" )                                              ;;
	( "version" )                 version                   ;;
	( "install_build_framework" ) install_build_framework   ;;
	( "emulate_jenkins" )         emulate_jenkins           ;;
	( "setup_environment" )       setup_environment         ;;
	( "print_environment" )       print_environment         ;;
	( "setup_mock" )              setup_mock                ;;
	( "clean" )                   clean                     ;;
	( "dev_build" )               dev_build                 ;;
        ( * ) echo "unexpected argument: $arg" ; usage ; exit 1 ;;
    esac
done

exit 0
