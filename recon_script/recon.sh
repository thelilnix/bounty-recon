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
# - massdns
# - unfurl
# - httprobe
# - Asnlookup
# - virtual-host-discovery
# - ffuf (maybe, I'm not sure :/)
# - c99 subdomain finder (maybe, I'm not sure :/)
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
    echo -e "\vUSAGE: ./recon.sh TOOLS_PATH\vExample: ./recon.sh ~/tools(without /)"
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
    export report_date="$(date +%d_%m_%Y-%H.%M)"
    mkdir -p recon/$report_date/
    export report_path="recon/$report_date"
fi

# Sublist3r
sublist3r() {
    $tools_path/Sublist3r/sublist3r.py -d $1 -t 5 > $report_path/$1/sublister.txt
}

# crt.sh
crtsh() {
    $tools_path/massdns/scripts/ct.py $1 2>/dev/null > $report_path/$1/tmp.txt
    [ -s $report_path/$1/tmp.txt ] && cat $report_path/$1/tmp.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/crtsh.txt
    cat $report_path/$1/subdomains.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/domaintemp.txt
}

# waybackurls
waybackurls() {
    cat $report_path/$1/urls.txt | waybackurls > $report_path/$1/wayback/waybackurls.txt
    cat $report_path/$1/wayback/waybackurls.txt | sort -u | unfurl --unique keys > $report_path/$1/wayback/paramlist.txt
    [ -s $report_path/$1/wayback/paramlist.txt ] && log "$report_path/$1/wayback/paramlist.txt saved"
}

# dirsearch
dirsearch() {
    cat $report_path/$1/urls.txt | xargs -P10 -I % sh -c "python3 $tools_path/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar -w $tools_path/dirsearch/db/dicc.txt -t 30 -u %" > $report_path/$1/dirsearch.txt
}

# nikto
nikto() {
    for target in $(cat $report_path/$1/urls.txt);do
        echo -e " $PURPLE=-=-=-=$YELLOW $target $PURPLE=-=-=-=$NOPE " >> $report_path/$1/nikto.txt
        nikto -h $target >> $report_path/$1/nikto.txt
    done
}

# knockpy
knockpy() {
    knockpy $1 -j > $report_path/$1/knock.txt
}

# virtual-host-discovery
vhostdiscovery() {
    ruby $tools_path/virtual-host-discovery/scan.rb --ip=$1 --host=domain.tld
}

# Asnlookup
asnlookup() {
    python3 $tools_path/Asnlookup/asnlookup.py -n "-A -T4" -o "$1"
}

# amass
amassf() {
    amass enum -d $1
}

