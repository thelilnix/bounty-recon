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
export chromium_bin_path='/usr/bin/brave-browser' # Change this

# TODO: out of scope

# ##################################################

# ################### TOOLS #######################
# - Sublist3r
# - crt.sh
# - waybackurls
# - dirsearch
# - https://github.com/sathishshan/Zone-transfer
# - DIG
# - curl
# - nmap
# - JSFScan.sh
# - deduplicate
# - gf
# - Dalfox
# - aquatone
# - unfurl
# - httprobe
# - xdg-open
# - massdns (not required)
# - Asnlookup (not required)
# - virtual-host-discovery (not required)
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
}

# crt.sh
crtsh() {
    log "crt.sh ($1)"
    $tools_path/massdns/scripts/ct.py $1 2>/dev/null > $report_path/$1/tmp.txt
    [ -s $report_path/$1/tmp.txt ] && cat $report_path/$1/tmp.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/crtsh.txt
    cat $report_path/$1/subdomains.txt | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S -w  $report_path/$1/domaintemp.txt
}

# nmap
nmapf() {
    log "Nmap ($1)"
    for ip in $(cat $report_path/$1/ip.txt);do
        log "$PURPLE--------------$GREEN $target $PURPLE---------------$NOPE" >> $report_path/$1/scans/nmap/result.txt
        nmap -A -T4 $ip >> $report_path/$1/scans/nmap/result.txt
    done
}

# extract IPs
ip_extractor() {
    log "IPs ($1)"
    for subdomain in $(cat $report_path/$1/subdomains.txt);do
        dig $1 +short >> $report_path/$1/ip.txt
    done
    cat $report_path/$1/ip.txt | sort -u > $report_path/$1/ip.txt
}

# waybackurls
wayback() {
    log "waybackurls ($1)"
    mkdir -p $report_path/$1/wayback/

    cat $report_path/$1/urls.txt | waybackurls > $report_path/$1/wayback/waybackurls.txt
    cat $report_path/$1/wayback/waybackurls.txt | deduplicate --sort | unfurl format %d%p?%q | sed "/?$/d" > $report_path/$1/wayback/paramlist.txt
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
    log "dirsearch ($2)"
    domain=$(echo $2 | unfurl domains)
    python3 $tools_path/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar -w $tools_path/dirsearch/db/dicc.txt -t 30 -u $2 -q -R 0 --plain-text-report=$report_path/$1/scans/dirsearch/$domain.txt &>/dev/null
}

# JSFScan.sh
JSFScan() {
    log "Working on JS ($1)"
    cd $tools_path/JSFScan.sh/ && $tools_path/JSFScan.sh/JSFScan.sh -l $absolute_path/$report_path/$1/urls.txt --all -r -o $absolute_path/$report_path/$1/scans/JS/ &>/dev/null
    cd $absolute_path
}

# virtual-host-discovery (not required)
vhostdiscovery() {
    log "virtual host discovery ($1)"
    ruby $tools_path/virtual-host-discovery/scan.rb --ip=$1 --host=domain.tld
}

# massdns (not required)
massdns() {
    log "massdns ($1)"
    $tools_path/massdns/scripts/subbrute.py $seclists_path/Discovery/DNS/clean-jhaddix-dns.txt $1 | $tools_path/massdns/bin/massdns -r $tools_path/massdns/lists/resolvers.txt -t A -q -o S | grep -v 142.54.173.92 > $report_path/$1/mass.txt
}

# Asnlookup (not required)
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
    cat $report_path/$1/subdomains.txt | sort -u | httprobe -c 50 -t 5000 >> $report_path/$1/live_hosts.txt
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
    dig $1 TXT +short > $report_path/$1/txt_records.txt
}

# Dalfox and gf
xss_scanner() {
    log "Working on XSS (paramlist.txt) ($1)"
    cat $report_path/$1/wayback/paramlist.txt | gf xss 2>/dev/null | dalfox pipe -out $report_path/$1/scans/XSS_check/dalfox.txt &>/dev/null
}

# aquatone
aquatonef() {
    log "aquatone ($1)"
    cat $report_path/$1/urls.txt | aquatone -chrome-path $chromium_bin_path -out $report_path/$1/scans/Aquatone/ -threads 5 -silent
}

# Report creator
report() {
    log "Creating the report..."
    # index.html
    echo "<!doctypehtml><html lang=en><meta charset=utf-8><meta content='width=device-width,initial-scale=1'name=viewport><link href=https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css rel=stylesheet crossorigin=anonymous integrity=sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl><link href=https://cdn.datatables.net/1.10.23/css/dataTables.bootstrap.min.css rel=stylesheet><title>Report - $1</title><body><style>body{background-color:#2c3e50}.paginate_button{position:relative;display:block;padding:.5rem .75rem;margin-left:-1px;line-height:1.25;color:#fff;background-color:#6c757d;border:1px solid #346767}.paginate_button.disabled .paginate_button{color:#868e96;pointer-events:none;cursor:auto;background-color:#6c757d;border-color:#346767}.paginate_button.active .paginate_button{z-index:1;color:#fff;background-color:#212529;border-color:#346767}.paginate_button:focus,.paginate_button:hover{color:#fff;text-decoration:none;background-color:#212529;border-color:#346767}label{color:rgba(255,255,255,.5)}.dataTables_info{color:rgba(255,255,255,.5)}a{color:#fff}</style><nav class='bg-dark fixed-top navbar navbar-dark navbar-expand-lg'><div class=container-fluid><a class=navbar-brand>Recon!</a> <button aria-controls=navbarNavAltMarkup aria-expanded=false aria-label='Toggle navigation'class=navbar-toggler data-bs-target=#navbarNavAltMarkup data-bs-toggle=collapse type=button><span class=navbar-toggler-icon></span></button><div class='collapse navbar-collapse'id=navbarNavAltMarkup><div class=navbar-nav><a class='nav-link active'aria-current=page>Subdomains</a> <a class=nav-link href=../scans/Aquatone/aquatone_report.html target=_blank>Aquatone</a> <a class=nav-link href=wayback.html>WayBackMachine</a> <a class=nav-link href=dns.html>DNS</a> <a class=nav-link href=dalfox.html>Dalfox</a> <a class=nav-link href=../scans/JS/report.html target=_blank>JSFScan</a> <a class=nav-link href=nmap.html>NMAP</a></div></div></div></nav><br><br><br><br><br><h3 class=text-white>Subdomain</h3><br><table cellspacing=0 class='table table-bordered table-dark table-sm table-striped'id=subdomain-table width=100%><thead><tr><th>Subdomain<th>Status Code<th>URLs<tbody>" >> $report_path/$1/report/index.html
    for line in $(cat $report_path/$1/subdomains.txt);do
        echo "<tr><td id='subdomain'>$line</td><td>$(curl -I http://$line 2>/dev/null | head -n 1 | cut -d$' ' -f2)</td><td>$(wc -l $report_path/$1/scans/dirsearch/$line.txt | awk '{print $1}')</td></tr>" >> $report_path/$1/report/index.html
    done
    echo "</tbody></table><br/><hr style='color: white;'/><br/><h3 class='text-white-50'>dirsearch result</h3><br/>" >> $report_path/$1/report/index.html
    for subdir in $(/usr/bin/ls -Al $report_path/$1/scans/dirsearch/*.txt | awk -F':[0-9]* ' '/:/{print $2}' | rev | cut -d"/" -f 1 | rev | sed "s/.txt//g");do
        echo "<pre style='color:white;'>$subdir <a href='file://$absolute_path/$report_path/$1/scans/dirsearch/$subdir.txt' class='btn btn-info'>Let's go</a></pre>" >> $report_path/$1/report/index.html
    done
    echo "<script src='https://code.jquery.com/jquery-3.5.1.js'></script><script src='https://cdn.datatables.net/1.10.23/js/jquery.dataTables.min.js'></script><script src='https://cdn.datatables.net/1.10.23/js/dataTables.bootstrap.min.js'></script><script>\$(document).ready(function() {\$('#subdomain-table').DataTable();} );</script><!-- Optional JavaScript; choose one of the two! --><!-- Option 1: Bootstrap Bundle with Popper --><script src='https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js' integrity='sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0' crossorigin='anonymous'></script><!-- Option 2: Separate Popper and Bootstrap JS --><!--<script src='https://cdn.jsdelivr.net/npm/@popperjs/core@2.6.0/dist/umd/popper.min.js' integrity='sha384-KsvD1yqQ1/1+IA7gi3P0tyJcT3vR+NdBTt13hSJ2lnve8agRGXTTyNaBYmCR/Nwi' crossorigin='anonymous'></script><script src='https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.min.js' integrity='sha384-nsg8ua9HAw1y0W1btsyWgBklPnCUAFLuTMS2G72MMONqmOymq585AcH49TLBQObG' crossorigin='anonymous'></script>--></body></html>" >> $report_path/$1/report/index.html
    # dns.html
    
    # nmap.html
    # dalfox.html
    # wayback.html
    xdg-open $report_path/$1/report/index.html
}

# Always clean your desk :)
clean_tmp() {
    log "Cleaning..."
    rm $report_path/$1/tmp.txt
    rm $report_path/$1/domaintemp.txt
    rm $report_path/$1/cleancrtsh.txt
}

if [ $# -ne 1 ];then
    usage
fi

if [ -s scope.txt ];then
    export tools_path="$1"
    export report_date="$(date +%d_%m_%Y-%H.%M)"
    mkdir -p recon/$report_date/
    export report_path="recon/$report_date"
    export absolute_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
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
        ip_extractor $scope
        live_hosts $scope
        wayback $scope
        # Recon 3 (scanning the hosts and subdomains)
        mkdir -p $report_path/$scope/scans/Aquatone
        mkdir -p $report_path/$scope/scans/nmap
        mkdir -p $report_path/$scope/scans/JS
        mkdir -p $report_path/$scope/scans/XSS_check
        mkdir -p $report_path/$scope/scans/dirsearch
        JSFScan $scope
        xss_scanner $scope
        aquatonef $scope
        nmapf $scope
        for url in $(cat $report_path/$scope/urls.txt);do
            dirsearch $scope $url
        done
        # Recon 4 (Reporting)
        mkdir -p $report_path/$scope/report
        clean_tmp $scope
        report $scope
    done
    log "Done! in $(($SECONDS/60)) min and $(($SECONDS%60)) seconds."
else
    error "scope.txt not found"
    exit 1
fi