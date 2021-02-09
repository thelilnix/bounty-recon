#!/bin/bash
# Created by Sam Ebison (https://github.com/ebsa491)

# A bug bouty program directory structure
#   leaked_data/ ( leaked data )
#   recon/       ( reconnaissance )
#   scope.txt    ( in-scope and out of scope )
#   note.txt     ( Some important notes )
#   TODO.md      ( TODO-list )
#   burp.json    ( Burp Suite configuration )
#   recon.sh     ( the recon script for automation )

if [[ $# != 1 ]];then
    echo "USAGE: ./create.sh TARGET_NAME"
    exit 1
fi

# Creating the program dir
echo -e "\033[1;33m Creating the bounty program dir...\033[0m"
mkdir $1

# Creating the structure
echo -e "\033[1;32m Creating the structure...\033[0m"
mkdir $1/leakped_data
mkdir $1/recon
touch $1/scope.txt
touch $1/note.txt
touch $1/TODO.md
cp recon_script/recon.sh $1/

echo -e "\033[1;32mDONE!\033[0m move the burp config to the directory manually!"

