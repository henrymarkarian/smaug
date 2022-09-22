#!/usr/bin/env bash

function main {
    if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$#" -lt 2 ]; then
        echo "Usage: smaug.sh <GitHub username> <project name>"
        echo "Options:"
        echo "  -h   print this help message"
        echo "  -a   download all versions"
        echo "  -d   print debug messages"
        exit 0
    fi

    while getopts ":i:da" opt; do
        echo $opt
        case $opt in
            d)
                DEBUG=true
                ;;
            a)
                ALL=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # if the folder smaug does not exist, create it
    if [ ! -d smaug ]; then
        mkdir smaug
    fi
    cd smaug
    curl -H "Accept: application/vnd.github+json" https://api.github.com/repos/"$1"/"$2"/releases > out
    grep -F "browser_download_url" out | sed -n "s/^[ \t]*\"browser_download_url\": \"\(.*\)\"$/\1/p" > out2
    for f in $(cat out2); do
        if [ "$DEBUG" == "true" ]; then
            echo "INFO - Found Repo: $f"
        fi
        echo "---- Download? (y/n) ----"
        if [ "$ALL" != "true" ]; then
            read -n 1 keypress
            echo
        fi
        if [ "$keypress" == "y" | "$ALL" == "true" ]; then
            echo "---- Downloading... ----"
            dest=$(echo $f | sed -n "s/^.*\/\(.*\)\.zip$/\1/p" | cat)
            curl -L "$f" -o "$dest"
        fi
    done
}

if [ "$0" == "$BASH_SOURCE" ]; then
  main "$@"
fi