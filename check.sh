#!/bin/bash
# Checks to see if there is an update to all 3rd party applications
# Author: Justin (justin@solus-project.com)
# Licensed under WTFPL

# Notices and Errors
function do_error {
    echo -e "\e[31mError\e[0m: $1"
    exit 1
}
function do_notice {
    echo -e "\e[93mNotice\e[0m: $1"
}

# Use a tmp dir for all work to keep it clean
if [[ ! -d /tmp/3rd-party-updater ]]; then
    mkdir /tmp/3rd-party-updater
fi
# Move to dir for all operations
cd /tmp/3rd-party-updater
# Clean up before we do anything
rm -rf /tmp/3rd-party-updater/*

# Package list
# Get a list of what's installed so we don't have to do it more times later
do_notice "Finding which packages are installed. This will take a moment..."
eopkg li | cut -d" " -f 1 | grep 'google-chrome-stable\|google-chrome-beta\|google-chrome-unstable\|opera-stable\|vivaldi-beta\|vivaldi-snapshot\|spotify' > /tmp/3rd-party-updater/installed
do_notice "Found the following 3rd party applications installed:"
cat /tmp/3rd-party-updater/installed

# Do the checks
for package in $(cat /tmp/3rd-party-updater/installed)
    do
        do_notice "Checking for updates for ${package}..."
        case ${package} in
            google-chrome-stable)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/google-chrome-stable/pspec.xml"
            ;;
            google-chrome-beta)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/google-chrome-beta/pspec.xml"
            ;;
            google-chrome-unstable)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/google-chrome-unstable/pspec.xml"
            ;;
            opera-stable)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/opera-stable/pspec.xml"
            ;;
            vivaldi-beta)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/vivaldi-beta/pspec.xml"
            ;;
            vivaldi-snapshot)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/network/web/browser/vivaldi-snapshot/pspec.xml"
            ;;
            spotify)
                url="https://raw.githubusercontent.com/solus-project/3rd-party/master/multimedia/music/spotify/pspec.xml"
            ;;
            *)
                echo "wut?!"
            ;;
        esac
        wget -q $url
        relno=$(cat pspec.xml | grep "<Update release=" | head -n 1 | cut -d"\"" -f 2)
        installedrelno=$(eopkg info ${package} | head -n 2 | tail -n 1 | cut -d":" -f 4 | sed 's/ //g')
        if [[ $relno -gt $installedrelno ]]
            then
                do_notice "Updating ${package} to release ${relno}. You will need to enter your password."
                sudo eopkg bi --ignore-safety ${url} &&
                files=(*.eopkg)
                if [ -e "${files[0]}" ];
                then
                    # Install the package
                    sudo eopkg it *.eopkg &&
                    # Move the eopkg to the cache
                    sudo mv *.eopkg /var/cache/eopkg/packages/ &&
                    do_notice "${package} cached in /var/cache/eopkg/packages/."
                else
                    do_error "Package failed to build, please try again or email justin@solus-project.com if you believe there is an issue with the package."
                fi
            else
                do_notice "No updates for ${package}"
        fi
        # Cleanup dir
        rm -rf *

done
