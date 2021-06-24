helpalias(){
    echo "findsubs:             get known subdomains (no brute force) and outputs to a file {DOMAIN}"
    echo "checkwildcard:        check if target domain allows brute force {DOMAIN}. If a number other than 0 is returned - brute force NOT possible."
    echo "probesubs:            run httprobe against a list of hosts {FILE}"
    echo "ampassive:            runs amass for reverse whois and passively for subdomains {DOMAIN}"
    echo "certgrab:             grab all known certs for domain and put into list"
    echo "flyover:              run aquatone with large ports selection against a list of hosts {FILE}"
    echo "ffufitup:             takes a list of URLs (https://example.com/) and runs ffuf, outputs to its own associated domain-name directory {FILE}"
    echo "ipinfo:               gets info about target {IP}"
    echo "gips:                 grep ips from a file, like amass's -src -ip output file or massdns's resolver output {FILE}"
    echo ""
    echo "getwebservers:        parse webservers from Nmap scan {.nmap}"
    echo "gports:               quickly get all the ports associated for each host {.gnmap}"
    echo "topnames:             look at the top names found for each service {.gnmap}"
    echo "topsids:              get the actual service identifiers {.gnmap}"
    echo "countports:           quickly get number of ports open for each host {.gnmap}"
    echo "awkports:             a pipe to look for ports associated with a specific service in grepable nmap output (ie: cat nmapresults.gnmap | grep weblogic | awkports)"
    echo "gsubnets:             parse list of IPs into subnets"

}

export SECLISTS="/CHANGE/THIS/TO/PATH/TO/SECLISTS"
export BIG="$SECLISTS/Discovery/Web-Content/big.txt"
export WEB="$SECLISTS/Discovery/Web-Content/"
export DIRS_LARGE="$SECLISTS/Discovery/Web-Content/raft-large-directories.txt"
export DIRS_SMALL="$SECLISTS/Discovery/Web-Content/raft-small-directories.txt"
export FILES_LARGE="$SECLISTS/Discovery/Web-Content/raft-large-files.txt"
export FILES_SMALL="$SECLISTS/Discovery/Web-Content/raft-small-files.txt"

ffufitup(){ # takes a list of URLs and uses dirs to run ffuf. modify dirs() as necessary
        for host in $(cat $1); do dirs $host;done | tee tmp
}

dirs(){ # ensure URLs end with trailing '/'                                                                                                  
        name=$(echo $1 | unfurl -u domains)
        x=$(date +%Y%m%d%H%M%S)                     
        mkdir -p ./ffufs       
        mkdir -p ./ffufs/$name                                                                                                                                                                                     
        ffuf -w $FILES_LARGE -u $1FUZZ -D -e asp,aspx,cgi,cfml,CFM,htm,html,json,jsp,php,phtml,pl,py,sh,shtml,sql,txt,xml,xhtml,tar,tar.gz,tgz,war,zip,swp,src,jar,java,log,bin,js,db -t 10 -o ./ffufs/$name/$name_$x.json
}

findsubs(){ # get known subdomains (no brute force)
    subfinder -d $1 -o ./subfinder_$1.txt
    amass enum -d $1 -o ./amass_subs_$1.txt
    certgrab $1
    cat ./subfinder_$1.txt ./amass_subs_$1.txt ./$1-hosts-crtsh.txt ./$1-hosts-certspotter.txt | sort -u > foundsubs_$1.txt
}

checkwildcard(){
    dig @1.1.1.1 A,CNAME {plzdontexist61235,getoutwildcard,kittycatsz}.$1 +short | wc -l
}

probesubs(){ # run httprobe against a list of hosts {FILE}
    cat $1 | httprobe -c 5 | tee -a httprobed-$1
}

ampassive(){ # runs amass for reverse whois and passively for subdomains
    amass intel -whois -d $1 -r 8.8.8.8 -o ./intel_amass_$1.txt
    amass enum --passive -d $1 -o passive_amass_$1
}

certgrab(){
    curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > $1-hosts-crtsh.txt
    curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u > $1-hosts-certspotter.txt
}

flyover() { #take active web server list from httprobe output and throw aquatone at it.
    cat $1 | aquatone -ports large
}

ipinfo(){ # gets info about target IP
    curl http://ipinfo.io/$1
}

gips(){ # grep ips from a file, like amass's -src -ip output file or something
    grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $1
}

getwebservers(){ # parse webservers from Nmap scan (.nmap)
    grep open $1 | grep -v "scan initiated" | tr -s " " | cut -d" " -f1-3 \
    | grep "\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbe m\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-ans werbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" \
    | cut -d"/" -f 1 | sort -u
}

gports(){ # quickly get all the ports associated for each host {.gnmap}
    egrep -v "^#|Status: Up" $1 | cut -d' ' -f2,4- | \
    sed -n -e 's/Ignored.*//p'  | \
    awk '{print "Host: " $1 " Ports: " NF-1; $1=""; for(i=2; i<=NF; i++) { a=a" "$i; }; split(a,s,","); for(e in s) { split(s[e],v,"/"); printf "%-8s %s/%-7s %s\n" , v[2], v[3], v[1], v[5]}; a="" }'
}

topnames(){ # look at the top names found for each service {.gnmap}
    egrep -v "^#|Status: Up" $1 | cut -d ' ' -f4- | tr ',' '\n' | \
    sed -e 's/^[ \t]*//' | awk -F '/' '{print $5}' | grep -v "^$" | sort | uniq -c \
    | sort -k 1 -nr
}

topsids(){ # get the actual service identifiers {.gnmap}
    egrep -v "^#|Status: Up" $1 | cut -d ' ' -f4- | tr ',' '\n' | \
    sed -e 's/^[ \t]*//' | awk -F '/' '{print $7}' | grep -v "^$" | sort | uniq -c \
    | sort -k 1 -nr
}

countports(){ # quickly get number of ports open for each host {.gnmap}
    egrep -v "^#|Status: Up" $1 | cut -d' ' -f2,4- | \
    sed -n -e 's/Ignored.*//p' | \
    awk -F, '{split($0,a," "); printf "Host: %-20s Ports Open: %d\n" , a[1], NF}' \
    | sort -k 5 -g
}

awkports(){ # a pipe to look for ports associated with a specific service (ie: cat nmapresults.gnmap | grep weblogic | awkports)
   awk '{printf "%s\t", $2;
      for (i=4;i<=NF;i++) {
        split($i,a,"/");
        if (a[2]=="open") printf ",%s",a[1];}
      print ""}' | sed -e 's/,//'
}

gsubnets(){ # parse list of IPs into subnets
    awk '{for(i=1;i<=NF;i++){split($i,a,".");cn=a[1]"."a[2]"."a[3]; if(cn != c){c=cn;printf("\n"c".0 ")};printf($i" ")}}END{printf("\n")}' $1 | cut -d " " -f1 | sort -u
}
