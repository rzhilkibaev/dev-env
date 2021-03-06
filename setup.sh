#!/usr/bin/env bash

# Usage: sudo setup.sh [name1] [name2] ...
#   where nameX is a name of the tool to install
# example: sudo ./setup.sh ansible vagrant
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.

main() {

    TOOL_NAMES=($@)
    #TOOL_NAMES+=(wget curl zip unzip git) # these are used by the other installers
    #TOOL_NAMES+=(python-pip python3-pip)
    #TOOL_NAMES+=(ansible)
    #TOOL_NAMES+=(awscli vagrant terraform)
    #TOOL_NAMES+=(sdkman) # sdkman can be used to install maven, ant, gradle, java...
    #TOOL_NAMES+=(n) # n can be used to install nodejs, npm...
    #TOOL_NAMES+=(nvim)
    #TOOL_NAMES+=(shell)
    #TOOL_NAMES+=(docker)
    #TOOL_NAMES+=(sshfs cifs-utils)
    #TOOL_NAMES+=(gnome-terminal)
    #TOOL_NAMES+=(tree vifm subversion ag)
    #TOOL_NAMES+=(misc)

    export SETUP_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    #echo SETUP_HOME=$SETUP_HOME

    # make the name of the init script available to the custom installers
    export INIT_SCRIPT=$SETUP_HOME/setup.d/_init

    # date -Iseconds is not supported on mac
    date -u +"%Y-%m-%dT%H:%M:%SZ" > setup.log

    for TOOL_NAME in ${TOOL_NAMES[@]}; do
        echo "============================================================" >> setup.log
        echo "Installing $TOOL_NAME" | tee -a setup.log
        # use custom installer if exists
        if [ -f $SETUP_HOME/setup.d/$TOOL_NAME ]; then
            # &>> doesn't work on mac
            $SETUP_HOME/setup.d/$TOOL_NAME 2>&1 >> setup.log
        else  # otherwise use common package installer 
            # &>> doesn't work on mac
            $SETUP_HOME/setup.d/install_package $TOOL_NAME 2>&1 >> setup.log
        fi
        if [ $? -ne 0 ]; then
            echo "Error occured while installing $TOOL_NAME, see setup.log"
        fi
    done

    echo Done
}

main $@
