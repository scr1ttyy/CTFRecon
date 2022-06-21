#!/bin/bash

# User Input
IP=$1
DIR_NAME=$2
PLATFORM=$3
WORDLIST=$4

# Regex Matching
RE='\.txt$'

# ASCII art
echo -e "\033[0;31m=================================================================="
echo -e "\033[0;31m=================================================================="
echo "                                                                  "
echo -e "\033[1;35m░█████╗░████████╗███████╗██████╗░███████╗░█████╗░░█████╗░███╗░░██╗"
echo -e "\033[1;35m██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗░██║"
echo -e "\033[1;35m██║░░╚═╝░░░██║░░░█████╗░░██████╔╝█████╗░░██║░░╚═╝██║░░██║██╔██╗██║"
echo -e "\033[1;35m██║░░██╗░░░██║░░░██╔══╝░░██╔══██╗██╔══╝░░██║░░██╗██║░░██║██║╚████║"
echo -e "\033[1;35m╚█████╔╝░░░██║░░░██║░░░░░██║░░██║███████╗╚█████╔╝╚█████╔╝██║░╚███║"
echo -e "\033[1;35m░╚════╝░░░░╚═╝░░░╚═╝░░░░░╚═╝░░╚═╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚══╝"
echo "                                                                  "
echo -e "\033[1;32mCreated By: hambyhacks"
echo "                                                                  "
echo -e "\033[1;36mTwitter: twitter.com/hambyhaxx"
echo -e "\033[1;33mGitHub:  github.com/hambyhacks"
echo -e "\033[1;37mMedium:  hambyhaxx.medium.com"
echo -e "\033[0;31m=================================================================="
echo -e "\033[0;31m=================================================================="
echo -e "                                                               "
echo -e "\033[1;32m[i] \033[0;37mStarting CTFRecon.sh..."
echo -e " "
sleep 1

# Check if user inputted necessary parameters (IP, Directory name, Platform)
if [ "$1" == "-h" ]
then
	echo -e "\033[0;32m[i] \033[0;37mUsage: \033[0;32m./ctfrecon.sh \033[1;34m[IP] [DIRECTORY_NAME] [PLATFORM] [WORDLIST]"	
	echo -e "\033[0;33m[w] \033[0;37mctfrecon is recommended to be run as \033[1;31mroot!"
elif (( $# != 4 ))
then
	echo -e "\033[0;31m[-] \033[0;31mError: \033[0;37mNumber of arguments passed: \033[1;31m$#"
	echo -e "\033[0;32m[i] \033[0;37mNumber of parameters required: \033[1;32m4"
	echo -e "\033[0;32m[i] \033[0;37mUsage: \033[1;32m./ctfrecon.sh \033[1;34m[IP] [Directory Name] [Platform] [Wordlist]"

elif ! [[ "$4" =~  $RE ]]
then
	echo -e "\033[0;31m[-] \033[0;37mError: \033[0;31mInvalid Wordlist!"
	echo -e "\033[0;31m[-] \033[0;37mExiting..."
	sleep 1
	exit 1

else

	# Check if directory exists
	if [ -d $DIR_NAME ]
	then
		echo -e "\033[0;31m[-] Error: \033[0;37mDirectory with the name: \033[1;31m${DIR_NAME} \033[0;37malready exists."
		sleep 1
		exit 1
	else
		mkdir -p $DIR_NAME/{loot,scans,ss,exploit}
		echo -e "\033[1;32m[+] \033[0;37mSuccessfully created \033[1;34m$DIR_NAME \033[0;37mdirectory!"
	fi

	# Sudo check
	if (($UID == 0))
	then
		# Check if there is similar IP in /etc/hosts file
		echo -e "\033[1;32m[i] \033[0;37mAdding \033[1;34m${DIR_NAME}.${PLATFORM} \033[0;37mto \033[0;32m/etc/hosts.."
		if grep -q "$IP" /etc/hosts
		then
			echo -e "\033[0;31m[-] \033[0;31mError: \033[0;37msimilar entry found in \033[0;32m/etc/hosts"
			sleep 1
			exit 1
		else 
			echo "$IP ${DIR_NAME}.${PLATFORM}" >> /etc/hosts 
			echo -e "\033[1;32m[+] \033[0;37mSuccessfully added \033[1;34m${DIR_NAME}.${PLATFORM} \033[0;37mto \033[0;32m/etc/hosts"

			# Scanning using nmap
			echo -e "\033[1;32m[+] \033[0;37mNow Scanning network using nmap.."
			nmap -T4 -A -Pn -p- -oN scans/${DIR_NAME}_nmap_scan.txt $IP >/dev/null

			echo -e "\033[1;32m[+] \033[0;37mNmap scan: \033[0;32mFinished"
			echo -e "\033[1;32m[+] \033[0;37mLog files saved at \033[0;32mscans/ \033[0;37mdirectory!\n"
			wait

			# Directory busting using GoBuster
			echo -e "\033[1;32m[i] \033[0;37mInitializing GoBuster for directory bruteforcing..."
			gobuster dir -u http://${DIR_NAME}.${PLATFORM} -w $WORDLIST -t 64 -o scans/${DIR_NAME}_GoBuster_scan.txt &>/dev/null
			wait
			echo -e "\033[1;32m[+] \033[0;37mLog files saved at scans directory!"
			echo -e "\033[1;32m[+] \033[0;37mGoBuster Directory Bruteforcing: \033[0;32mFinished"

			# Cleaning permissions of directories
			chmod 755 $(pwd)/$DIR_NAME/
			chown -R 1000:1000 $(pwd)/$DIR_NAME/
		fi

	else
		echo -e "\033[0;31m[-] Error: \033[0;37mPlease run ctfrecon as \033[1;31mroot!"
		echo -e "\033[0;31m[-] \033[0;37mExiting..."
		sleep 1
		exit 1
	fi
fi
