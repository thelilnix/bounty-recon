#!/bin/bash
# Created by Sam Ebison (https://github.com/ebsa491)
# Thank @nahamsec for his awesome script (https://github.com/nahamsec)

# #################################################
#                   Settings                      #
# #################################################

export RED="\033[1;31m"
export GREEN="\033[1;32m"
export BLUE="\033[1;36m"
export YELLOW="\033[1;33m"
export PURPLE="\033[1;35m"
export NOPE="\033[0m"

export seclists_path='~/wordlists/SecLists' # (without /)

# TODO: wildcard (*) scopes. and out of scope

# ##################################################

# ################### TOOLS #######################
# - Sublist3r
# - crt.sh
# - waybackurls
# - dirsearch
# - nikto
# - massdns
# - https://github.com/sathishshan/Zone-transfer
# - DIG
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

# Sublist3r
sublist3r() {
    log "Sublist3r ($1)"
    $tools_path/Sublist3r/sublist3r.py -d $1 -t 5 -o $report_path/$1/subdomains.txt &>/dev/null
    # Check for out of scope
}

# crt.sh
crtsh() {
    log "crt.sh ($1)"
    $tools_path/massdns/scripts/ct.py $1 2>/dev/null > $report_path/$1/tmp.txt
    [ -s $report_path/$1/tmp.txt ] && cat $report_path/$1/tmp.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/crtsh.txt
    cat $report_path/$1/subdomains.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/domaintemp.txt
}

# waybackurls
wayback() {
    log "waybackurls ($1)"
    mkdir -p $report_path/$1/wayback/

    cat $report_path/$1/urls.txt | waybackurls > $report_path/$1/wayback/waybackurls.txt
    cat $report_path/$1/wayback/waybackurls.txt | sort -u | unfurl --unique keys > $report_path/$1/wayback/paramlist.txt
    [ -s $report_path/$1/wayback/paramlist.txt ] && log "$report_path/$1/wayback/paramlist.txt saved"

    cat $report_path/$1/wayback/waybackurls.txt | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > $report_path/$1/wayback/jsurls.txt
    [ -s $report_path/$1/wayback/jsurls.txt ] && log "JS Urls saved to $report_path/$1/wayback/jsurls.txt"

    cat $report_path/$1/wayback/waybackurls.txt | sort -u | grep -P "\w+\.php(\?|$) | sort -u " > $report_path/$1/wayback/phpurls.txt
    [ -s $report_path/$1/wayback/phpurls.txt ] && log "PHP Urls saved to $report_path/$1/wayback/phpurls.txt"

    cat $report_path/$1/wayback/waybackurls.txt | sort -u | grep -P "\w+\.aspx(\?|$) | sort -u " > $report_path/$1/wayback/aspxurls.txt
    [ -s $report_path/$1/wayback/aspxurls.txt ] && log "ASP Urls saved to $report_path/$1/wayback/aspxurls.txt"

    cat $report_path/$1/wayback/waybackurls.txt | sort -u | grep -P "\w+\.jsp(\?|$) | sort -u " > $report_path/$1/wayback/jspurls.txt
    [ -s $report_path/$1/wayback/jspurls.txt ] && log "JSP Urls saved to $report_path/$1/wayback/jspurls.txt"
}

# dirsearch
dirsearch() {
    log "dirsearch ($1)"
    cat $report_path/$1/urls.txt | xargs -P10 -I % sh -c "python3 $tools_path/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar -w $tools_path/dirsearch/db/dicc.txt -t 30 -u %" > $report_path/$1/dirsearch.txt
}

# nikto
niktof() {
    for target in $(cat $report_path/$1/urls.txt);do
        echo -e " $PURPLE=-=-=-=$YELLOW $target $PURPLE=-=-=-=$NOPE " | tee -a $report_path/$1/nikto.txt
        nikto -h $target >> $report_path/$1/nikto.txt
    done
}

# virtual-host-discovery
vhostdiscovery() {
    log "virtual host discovery ($1)"
    ruby $tools_path/virtual-host-discovery/scan.rb --ip=$1 --host=domain.tld
}

# massdns (not required)
massdns() {
    log "massdns ($1)"
    $tools_path/massdns/scripts/subbrute.py $seclists_path/Discovery/DNS/clean-jhaddix-dns.txt $1 | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S | grep -v 142.54.173.92 > $report_path/$1/mass.txt
}

# Asnlookup
asnlookup() {
    log "asnlookup ($1)"
    python3 $tools_path/Asnlookup/asnlookup.py -n "-A -T4" -o "$report_path/$1/asnlookup.txt"
}

# Zone-transfer
zone_transfer() {
    log "Checking zone transfer ($1)"
    $tools_path/Zone-transfer/zone-t.sh $1 | tee $report_path/$1/zone_transfer.txt
}

# live hosts
live_hosts() {
    log "Searching for live hosts ($1)"
    cat $report_path/$1/subdomains.txt | sort -u | httprobe -c 50 -t 3000 >> $report_path/$1/live_hosts.txt
    cat $report_path/$1/live_hosts.txt | sed 's/\http\:\/\///g' | sed 's/\https\:\/\///g' | sort -u | while read line; do
    probeurl=$(cat $report_path/$1/live_hosts.txt | sort -u | grep -m 1 $line)
    echo "$probeurl" >> ./$report_path/$1/urls.txt
    done
    echo "$(cat $report_path/$1/urls.txt | sort -u)" > $report_path/$1/urls.txt
    log "Total of $(wc -l $report_path/$1/urls.txt | awk '{print $1}') live subdomains were found"
}

# CNAME TXT NS
cname_ns_txt_records() {
    log "Checking CNAME NS TXT records ($1)"
    # dig +nocmd $1 cname +noall +answer >> $report_path/$1/cname_records.txt (without crt.sh)
    # dig +nocmd $1 txt +noall +answer >> $report_path/$1/txt_records.txt (without crt.sh)
    cat $report_path/$1/crtsh.txt | awk '{print $3}' | sort -u | while read line; do
        wildcard=$(cat $report_path/$1/crtsh.txt | grep -m 1 $line)
        echo "$wildcard" >> $report_path/$1/cleancrtsh.txt
    done

    cat $report_path/$1/cleancrtsh.txt | grep CNAME >> $report_path/$1/cname_records.txt
    cat $report_path/$1/cname_records.txt | sort -u | while read line; do
        hostrec=$(echo "$line" | awk '{print $1}')
        if [[ $(host $hostrec | grep NXDOMAIN) != "" ]];then
            log "Check the following domain for NS takeover:  $line"
            echo "$line" >> $report_path/$1/ns_takeover.txt
        else
            warning "working on it..."
        fi
    done
    cat $report_path/$1/cleancrtsh.txt | grep TXT >> $report_path/$1/txt_records.txt
}

main() {
    if [ -s scope.txt && -s out-of-scope.txt ];then
        for scope in $(cat scope.txt);do
            # Recon 1 (Subdomains and DNS records)
            log "Starting recon ($scope)"
            scope="$(echo $scope | unfurl format %r.%t)"
            mkdir -p $report_path/$scope/
            sublist3r $scope
            zone_transfer $scope
            crtsh $scope
            cname_ns_txt_records $scope
            # Recon 2 (live hosts and ...)
            live_hosts $scope
            wayback $scope
            # for subdomain in $(cat $report_path/$scope/subdomains.txt);do
            #     # Recon 3 (scanning the hosts and subdomains)
            # done
        done
    else
        error "scope.txt/out-of-scope.txt not found"
        exit 1
    fi
}

if [[  $# != 1  ]];then
    usage
else
    export tools_path="$1"
    export report_date="$(date +%d_%m_%Y-%H.%M)"
    mkdir -p recon/$report_date/
    export report_path="recon/$report_date"
fi
main
