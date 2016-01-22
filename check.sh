#!/bin/bash
# Checks to see if there is an update to all 3rd party applications
# Author: Justin (justin@solus-project.com
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
cd /tmp/3rd-party-updater
rm -rf *

# Package list
packages="google-chrome-stable google-chrome-beta google-chrome-unstable opera-stable vivaldi-beta vivaldi-snapshot spotify"

# Temp measure
clear
for package in $packages
    do
        installed=$(eopkg li | grep $package | wc -l)
        if [[ $installed -eq 1 ]]
            then
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
                        do_notice "Updating ${package} to release number ${relno}. You will need to enter your password."
                        sudo eopkg bi --ignore-safety ${url} &&
                        sudo eopkg it *.eopkg &&
                        # Move the eopkg to the cache
                        sudo mv *.eopkg /var/cache/eopkg/packages/ &&
                        do_notice "{package} cached in /var/cache/eopkg/packages/."
                    else
                        do_notice "No updates for ${package}"
                fi
                if [[ -f pspec.xml ]];then rm pspec.xml;fi
        fi
done
