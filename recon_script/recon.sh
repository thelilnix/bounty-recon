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
# - massdns
# - amass
# - https://github.com/sathishshan/Zone-transfer
# - unfurl
# - httprobe
# - Asnlookup
# - virtual-host-discovery
# - ffuf
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
    echo -e "USAGE: ./recon.sh TOOLS_PATH\vExample: ./recon.sh ~/tools(without /)"
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
    log "Sublist3r ($1)"
    $tools_path/Sublist3r/sublist3r.py -d $1 -t 5 -o $report_path/$1/sublister.txt >/dev/null
    log "DONE!"
}

# crt.sh
crtsh() {
    log "crt.sh ($1)"
    $tools_path/massdns/scripts/ct.py $1 2>/dev/null > $report_path/$1/tmp.txt
    [ -s $report_path/$1/tmp.txt ] && cat $report_path/$1/tmp.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/crtsh.txt
    cat $report_path/$1/subdomains.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/domaintemp.txt
    log "DONE!"
}

# waybackurls
waybackurls() {
    log "waybackurls ($1)"
    mkdir -p $report_path/$1/wayback/
    cat $report_path/$1/urls.txt | waybackurls > $report_path/$1/wayback/waybackurls.txt
    cat $report_path/$1/wayback/waybackurls.txt | sort -u | unfurl --unique keys > $report_path/$1/wayback/paramlist.txt
    [ -s $report_path/$1/wayback/paramlist.txt ] && log "$report_path/$1/wayback/paramlist.txt saved"
}

# dirsearch
dirsearch() {
    log "dirsearch ($1)"
    cat $report_path/$1/urls.txt | xargs -P10 -I % sh -c "python3 $tools_path/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar -w $tools_path/dirsearch/db/dicc.txt -t 30 -u %" > $report_path/$1/dirsearch.txt
    log "DONE!"
}

# nikto
nikto() {
    for target in $(cat $report_path/$1/urls.txt);do
        echo -e " $PURPLE=-=-=-=$YELLOW $target $PURPLE=-=-=-=$NOPE " | tee -a $report_path/$1/nikto.txt
        nikto -h $target >> $report_path/$1/nikto.txt
    done
}

# virtual-host-discovery
vhostdiscovery() {
    log "virtual host discovery ($1)"
    ruby $tools_path/virtual-host-discovery/scan.rb --ip=$1 --host=domain.tld
    log "DONE!"
}

# Asnlookup
asnlookup() {
    log "asnlookup ($1)"
    python3 $tools_path/Asnlookup/asnlookup.py -n "-A -T4" -o "$1"
    log "DONE!"
}

# amass
amassf() {
    log "amass ($1)"
    amass enum -d $1 > $report_path/$1/amass.txt
    log "DONE!"
}

# Zone-transfer
zone_transfer() {
    log "Checking zone transfer ($1)"
    $tools_path/Zone-transfer/zone-t.sh $1 | tee $report_path/$1/zone_transfer.txt
}

# Custom function : for removing duplicates
merge_subdomain() {
    log "Removing duplicates ($1)..."
    cat $report_path/$1/amass.txt $report_path/$1/sublister.txt | unfurl domains | sort | uniq -u >> $report_path/$1/subdomains.txt
    log "DONE!"
}

# CNAMES
cname_reconds() {
    
}

main() {
    if [ -s scope.txt ];then
        for target in $(cat scope.txt);do
            log "Starting recon ($target)"
            target="$(echo $target | unfurl format %r.%t)"
            mkdir -p $report_path/$target/
            sublist3r $target
            amassf $target
            merge_subdomain $target
            zone_transfer $target
            crtsh $target
        done
    else
        error "scope.txt not found"
        exit 1
    fi
}

main
