#!/usr/bin/env bash

# Usage: setup.sh
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.

main() {

    TOOL_NAMES=()
    TOOL_NAMES+=(wget curl zip unzip git) # these are used by the other installers
    #TOOL_NAMES+=(python-pip python3-pip)
    #TOOL_NAMES+=(ansible vagrant terraform)
    #TOOL_NAMES+=(sdkman) # sdkman can be used to install maven, ant, gradle, java...
    #TOOL_NAMES+=(nvm) # nvm can be used to install nodejs, npm...
    #TOOL_NAMES+=(nvim)
    TOOL_NAMES+=(shell)
    #TOOL_NAMES+=(sshfs cifs-utils)
    #TOOL_NAMES+=(gnome-terminal)
    #TOOL_NAMES+=(tree vifm subversion ag)
    #TOOL_NAMES+=(misc)

    export SETUP_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    echo SETUP_HOME=$SETUP_HOME

    export INIT_SCRIPT=$SETUP_HOME/setup.d/_init

    date -Iseconds > setup.log

    for TOOL_NAME in ${TOOL_NAMES[@]}; do
        echo $TOOL_NAME
        # use dedicated installer if exists
        if [ -f $SETUP_HOME/setup.d/$TOOL_NAME ]; then
            $SETUP_HOME/setup.d/$TOOL_NAME &>> setup.log
        else  # otherwise use common package installer 
            $SETUP_HOME/setup.d/install_package $TOOL_NAME &>> setup.log
        fi
        if [ $? -ne 0 ]; then
            cat setup.log
        fi
    done

    cat setup.log

    echo Done
}

main
