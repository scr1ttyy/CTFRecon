#!/usr/bin/zsh

# User Input
IP=$1
DIR_NAME=$2

# Create directory inputted by user.
mkdir $DIR_NAME
cd $DIR_NAME/
mkdir $IP/
cd $IP/
mkdir loot scans ss exploit
clear
echo "Successfully created $DIR_NAME directory!"
echo "$IP ${DIR_NAME}.htb" >> /etc/hosts
echo "Successfully added ${DIR_NAME}.htb to /etc/hosts"

# Run scanning scripts
echo "Now Scanning..."
echo "Log files saved at scans/ directory!"
nmap -T4 -A -p- -oN scans/${DIR_NAME}_nmap_scan.txt $IP >/dev/null
wait
echo "Nmap scan: Finished"
gobuster dir -u http://${DIR_NAME}.htb -w /usr/share/seclists-git/Discovery/Web-Content/directory-list-2.3-medium.txt -t 64 -o scans/${DIR_NAME}_GoBuster_scan.txt &>/dev/null
wait
echo "GoBuster Directory Scan: Finished"
