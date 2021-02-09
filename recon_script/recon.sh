#!/bin/bash
# Created by Sam Ebison (https://github.com/ebsa491)

# #################################################
#                   Settings                      #
# #################################################

export RED="\033[1;31m"
export GREEN="\033[1;32m"
export BLUE="\033[1;36m"
export YELLOW="\033[1;33m"
export PURPLE="\033[1;35m"
export NOPE="\033[0m"

export seclists_path='~/wordlists/SecLists/' # Don't forget / at the end of this variable

# ##################################################

# ################### TOOLS #######################
# - Sublist3r
# - crt.sh
# - waybackurls
# - dirsearch
# - nikto
# - Knockpy
# - webscreenshot
# - unfurl
# - httprobe
# - ffuf (maybe, I'm not sure :/)
# - c99 subdomain finder (maybe, I'm not sure :/)
# - Asnlookup (maybe, I'm not sure :/)
# - virtual-host-discovery (maybe, I'm not sure :/)
# - massdns (maybe, I'm not sure :/)
# - aquatone (maybe, I'm not sure :/)
# ################################################

echo -e "$BLUE
██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗██╗
██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║██║
██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║██║
██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║╚═╝
██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║██╗
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝
$NOPE"

usage() {
    echo -e "\vUSAGE: ./recon.sh TOOLS_PATH\vExample: ./recon.sh ~/tools/"
    exit 1
}

error() {
    echo -e "[$RED-$NOPE] $1"
}

warning() {
    echo -e "[$YELLOW!$NOPE] $1"
}

log() {
    echo -e "[$GREEN+$NOPE] $1"
}

if [[  $# != 1  ]];then
    usage
else
    export tools_path="$1"
fi

