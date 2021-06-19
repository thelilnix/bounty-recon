#!/bin/bash
# Created by Sam Ebison (https://github.com/ebsa491)

# A bug bouty program directory structure
#   leaked_data/ ( leaked data )
#   recon/       ( reconnaissance )
#   scope.txt    ( in-scope )
#   out_of_scope.txt ( out of scope )
#   note.md     ( Some important notes )
#   burp.json    ( Burp Suite configuration )

if [[ $# != 1 ]];then
    echo "USAGE: ./create.sh TARGET_NAME"
    exit 1
fi

# Creating the program dir
echo -e "\033[1;33m Creating the bounty program dir...\033[0m"
mkdir $1

# Creating the structure
echo -e "\033[1;32m Creating the structure...\033[0m"
mkdir $1/leaked_data
touch $1/scope.txt
touch $1/out_of_scope.txt
touch $1/note.md

echo -e "\033[1;32mDONE!\033[0m move the burp config to the directory manually! and run recon.sh"

