#!/bin/bash

#===============================================================================
#
#          FILE:  copy.sh
#
#         USAGE:  ./copy.sh
#
#   DESCRIPTION: It runs backups of all Subversion repositories into
#   the same directory at once and store them into a same target directory.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#         NOTES:  ---
#        AUTHOR:  Edson A. Soares, edson.araujo.soares@gmail.com
#       CREATED:  08/03/2017
#===============================================================================

source util.sh

readonly SCRIPT_VERSION=2017/01/14;
readonly DEFAULT_CONCURRENT_BACKUP_ALLOWED=2
readonly DEFAULT_TARGET_ROOT_DIRECTORY_NAME=subversion_backup_utility

target_root_directory=
source_root_directory=
concurrent_backups_allowed=

#===  FUNCTION  ================================================================
#          NAME: usage
#   DESCRIPTION: It shows the options available for the script.
#
#    PARAMETERS:
#       RETURNS:
#===============================================================================
usage () {

    about
    howto="\
       or: $0 [ARGUMENT]... -s SOURCE DIRECTORY
       or: $0 [OPTION]...   -t TARGET DIRECTORY
       or: $0 [OPTION]...   -q NUMBER

    Arguments:
        -s SOURCE DIRECTORY set the DIRECTORY from where the backup will be performed FROM.

    Options:
        --help              display this help and exit.
        --version           display version info and exit.

        -t TARGET DIRECTORY set the DIRECTORY where the backup will be carried out.
        -q QUANTITY         set the amount of backups allowed into this DIRECTORY at the same time.
    "

    echo -e "$howto"

}

while test $# -ne 0; do

    case $1 in

        --help) usage; exit $?;;

        --version) echo "$0 $SCRIPT_VERSION"; exit $?;;

        -q)
            if test -z $2; then
                echo "The QUANTITY property cannot be empty." >&2
                exit 1;
            fi

            if test ! $2 -ge 1; then
                echo "It should there be at least one backup copy." >&2
                exit 1;
            fi

            concurrent_backups_allowed=$2
            shift;;

        -t)
            if test -z $2; then
                echo "target backup directory cannot be empty." >&2
                exit 1;
            fi

            if test ! -d  $2; then
                echo "$2: is not a valid backup target directory." >&2
                exit 1;
            fi

            target_root_directory=$2
            shift;;

        -s)
            if test -z $2; then
                echo "Backup source directory cannot be empty." >&2
                exit 1;
            fi

            if test ! -d  $2; then
                echo "$2: is not a valid Subversion repository directory." >&2
                exit 1;
            fi

            source_root_directory=$2
            shift;;

        --) shift
            break;;

        -*) echo "$0: Invalid option: $1" >&2
            exit 1;;

        *)  break;;

    esac
    shift

done

#===  FUNCTION  ================================================================
#          NAME: init
#   DESCRIPTION: It sets the default values to all variables of the program.
#    PARAMETERS:
#       RETURNS:
#===============================================================================
init () {

    about

    if test -z  $source_root_directory; then
        echo -e "Backup source directory cannot be empty. \nType --help for further information." >&2
        exit 1;
    fi

    if test -z  $target_root_directory; then
        if test ! -d "$HOME/$DEFAULT_TARGET_ROOT_DIRECTORY_NAME"; then
            mkdir -p "$HOME/$DEFAULT_TARGET_ROOT_DIRECTORY_NAME"
        fi
        target_root_directory=$HOME/$DEFAULT_TARGET_ROOT_DIRECTORY_NAME
    fi

    if test -z  $concurrent_backups_allowed; then
        concurrent_backups_allowed=$DEFAULT_CONCURRENT_BACKUP_ALLOWED
    fi

}

#===  FUNCTION  ================================================================
#          NAME: create_new_backup_directory
#   DESCRIPTION: It creates a new directory for a new backup copy storage.
#    PARAMETERS:
#       RETURNS: The path to the new directory that has created.
#===============================================================================
create_new_backup_directory () {

    local new_directory_path=$target_root_directory"/"$(create_backup_directory_name)
    mkdir -p $new_directory_path
    echo "$new_directory_path"

}

#===  FUNCTION  ================================================================
#          NAME: create_backup_directory_name
#   DESCRIPTION: It creates a datetime based name for the backup directory.
#    PARAMETERS:
#       RETURNS: The name for the new directory.
#===============================================================================
create_backup_directory_name () {

    local directory_name=`date +%Y-%m-%d"-"%H-%M-%S`
    echo "$directory_name"

}

#===  FUNCTION  ================================================================
#          NAME: count_backup_directories
#   DESCRIPTION: It counts the amount of backup copies.
#    PARAMETERS:
#       RETURNS: The amount of backups into the target directory.
#===============================================================================
count_backup_directories () {

    local quantity=$(find ${target_root_directory} -type d ! -path ${target_root_directory} | wc -l)
    echo "$quantity"

}

#===  FUNCTION  ================================================================
#          NAME: run_backup_copy_to
#   DESCRIPTION: It runs a backup copy for all Subversion repositories
#    PARAMETERS: The target directory where the backups have to be saved.
#       RETURNS:
#===============================================================================
run_backup_copy_to () {

    local backup_target_directory=$1
    local repositories_names_list=$(get_subdirectories_list ${source_root_directory})
    for repository_name in $repositories_names_list; do

        repository_source_path=$source_root_directory"/"$repository_name
        backup_target_file_path=$backup_target_directory"/"$repository_name

        if test $(is_package_installed "svnadmin") == false; then
            echo -e "It was not possible run the script. \nSubversion is not installed on the machine." >&2
            exit 1;
        fi
        svnadmin dump $repository_source_path > ${backup_target_file_path}".dump"

    done

}

#===  FUNCTION  ================================================================
#          NAME: run_backups_cleanup
#   DESCRIPTION: It runs a backup removal if and only if there are more backups
#       than allowed inside the backup target directory. The last backup will be
#       removed.
#
#    PARAMETERS:
#       RETURNS:
#===============================================================================
run_backups_cleanup () {

    local actual_backups_quantity=$(count_subdirectories ${target_root_directory})
    while test $actual_backups_quantity -gt $concurrent_backups_allowed; do

        local oldest_backup=$(get_oldest_subdirectory_name ${target_root_directory})
        rm -rf  $target_root_directory"/"$oldest_backup
        actual_backups_quantity=$(( actual_backups_quantity - 1 ))

    done

}

main () {

    init
    run_backup_copy_to $(create_new_backup_directory)
    run_backups_cleanup
    echo "Done. Backup was create at $target_root_directory"

}

main
