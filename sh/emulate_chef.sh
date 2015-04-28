# This file is a submodule of ../build.sh.

emulate_chef_help()
{
   echo 
   echo emulate_chef
   echo ------------
   echo "Installs the frameworks required for the build to work."
   echo "These frameworks are typically installed directly on the build machine."
   echo "In general, this installation needs to be done once for many builds."
   echo 
   echo "On Altiscale jenkins machines, this installation must be done by chef."
   echo
   echo "This script provides equivalent functionality so that developers"
   echo "(inside and outside Altiscale) can emulate the environment that"
   echo "Altiscale installs on jenkins slaves via chef."
}

# For information about mock, see: https://fedoraproject.org/wiki/Projects/Mock
install_mock()
{
    sudo yum install -y mock
    sudo usermod -a -G mock $USER
}

set_up_drive()
{
    # BASEDIR should typically use local, fast storage
    # Should have the same default as in emulate_jenkins.sh
    : ${BASEDIR:=/mnt/ssdb/$USER}

    sudo mkdir -p $BASEDIR
    sudo chown $USER:mock $BASEDIR
}

emulate_chef()
{
    if (($HELP)) ; then emulate_chef_help ; return ; fi

    install_mock
    set_up_drive
}