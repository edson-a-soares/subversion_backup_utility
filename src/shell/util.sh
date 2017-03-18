#!/bin/bash

#===============================================================================
#
#          FILE:  util.sh
#
#         USAGE:  source util.sh
#
#   DESCRIPTION: It holds many functions useful to other scripts for common
#       purposes.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#         NOTES:  ---
#        AUTHOR:  Edson A. Soares, edson.araujo.soares@gmail.com
#       CREATED:  08/03/2017
#===============================================================================

#===  FUNCTION  ================================================================
#          NAME: about
#   DESCRIPTION: It shows the description of the script.
#
#    PARAMETERS: ---
#       RETURNS: ---
#===============================================================================
about () {

    local header="\
    Subversion Backup Utility
    \nCopyright(C) 2017 Edson A. Soares. All rights reserved. <edson.araujo.soares@gmail.com>\n"
    echo -e $header

}

#===  FUNCTION  ================================================================
#          NAME: get_subdirectories_list
#   DESCRIPTION: It gets the names of the subdirectories inside a common root
#                directory.
#    PARAMETERS: The path to the root directory.
#       RETURNS: The list of the names of the subdirectories.
#===============================================================================
get_subdirectories_list () {

    local from=$1
    if test -z "$(ls -A $from)"; then
        echo -e "Source directory $from is empty." >&2
        exit 1;
    fi

    local list_names=$(cd ${from} && ls -d *)
    echo "$list_names"

}

#===  FUNCTION  ================================================================
#          NAME: get_oldest_subdirectory_name
#   DESCRIPTION: It gets the name of the oldest directory into a common root
#                directory.
#    PARAMETERS: The path to the root directory.
#       RETURNS: The name of the oldest subdirectory.
#===============================================================================
get_oldest_subdirectory_name () {

    local where=$1
    if test -z "$(ls -A $where)"; then
        echo -e "It is impossible to get any subdirectory. Directory $where is empty." >&2
        exit 1;
    fi

    local oldest=$(cd ${where} && ls -tr | head -n 1)
    echo "$oldest"

}

#===  FUNCTION  ================================================================
#          NAME: get_repository_revision
#   DESCRIPTION: It gets the current revision of a Subversion repository.
#
#    PARAMETERS: The path to the repository.
#       RETURNS: The current revision of the repository.
#===============================================================================
get_repository_revision () {

    local repository_path=$1
    local revision=$(svn info $repository_path -r 'HEAD' | grep Revision | egrep -o "[0-9]+")
    echo $revision

}

#===  FUNCTION  ================================================================
#          NAME: count_subdirectories
#   DESCRIPTION: Count the amount of directories inside some common root directory.
#    PARAMETERS: The common root directory path.
#       RETURNS: The amount of subdirectories.
#===============================================================================
count_subdirectories () {

    local source_directory=$1
    local counter=$(find ${source_directory} -type d ! -path ${source_directory} | wc -l)
    echo "$counter"

}

#===  FUNCTION  ================================================================
#          NAME: is_package_installed
#   DESCRIPTION: It checks if a package is installed.
#    PARAMETERS: The package name.
#       RETURNS: It returns true if the package is installed and false otherwise.
#===============================================================================
is_package_installed () {

    local name=$1
    local result=false

    which ${name} > /dev/null
    if test $? -eq 0; then
        result=true
    fi

    echo "$result"

}
