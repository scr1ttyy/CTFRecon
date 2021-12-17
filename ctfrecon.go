package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"regexp"
)

func main() {
	// Set Flags
	ip := flag.String("u", "", "IP Address (Required)")
	dir := flag.String("d", "", "Name of directory to be created. (Required)")
	platform := flag.String("p", "", "Platform (e.g., TryHackMe or HTB to .thm, .htb respectively) (Required)")
	wordlist := flag.String("w", "/usr/share/seclists-git/Discovery/Web-Content/directory-list-2.3-medium.txtf", "Wordlist to use for Directory Busting. (Required)")
	flag.Parse()

	// Checking for necessary components to run ctfrecon
	regex_text, err := regexp.MatchString(".txt", *wordlist)
	dir_name := []string{"exploit", "loot", "scans", "ss"}
	hosts_file, err := os.OpenFile("/etc/hosts", os.O_APPEND|os.O_WRONLY, 644)
	nmap_loc, err := exec.LookPath("nmap")
	gobuster_loc, err := exec.LookPath("gobuster")
	user, err := user.Current()

	// nmap Struct
	nmapCmd := &exec.Cmd{
		Path:   nmap_loc,
		Args:   []string{nmap_loc, "-T4", "-sC", "-sV", "-oN", *dir + "/" + *ip + "/" + "scans" + "/" + *dir + "-" + "nmap_scan.txt", "-p-", *ip},
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}
	// GoBuster Struct
	gobusterCmd := &exec.Cmd{
		Path:   gobuster_loc,
		Args:   []string{gobuster_loc, "dir", "-u", "http://" + *ip, "-w", *wordlist},
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}

	// Command Line Arguments check and user status
	if len(os.Args) != 5 || regex_text == false || user.Username != "0" {
		fmt.Println("[-] CTFRecon must be run as root! Check the number of arguments passed and wordlist should be in .txt!")
		flag.PrintDefaults()
		os.Exit(1)
	} else {
		//	Main Program

		//	Creating Directory name specified by user.
		os.MkdirAll(*dir+"/"+*ip, 755)
		for _, dir_create := range dir_name {
			os.MkdirAll(*dir+"/"+*ip+"/"+dir_create, 755)
		}
		// Appending Command Line argument dir to /etc/hosts
		if err != nil {
			log.Println(err)
		}
		defer hosts_file.Close()
		if _, err := hosts_file.WriteString(*ip + " " + *dir + "." + *platform + "\n"); err != nil {
			log.Fatal(err)
		}
		// Running nmap scan
		if err := nmapCmd.Run(); err != nil {
			fmt.Println("Error: ", err)
		}
		// Running gobuster scan
		if err := gobusterCmd.Run(); err != nil {
			fmt.Println("Error: ", err)
		}

		// TEST OUTPUT
		fmt.Printf("IP:%s\nDIR:%s\nPLATFORM:%s\nWORDLIST:%s\n", *ip, *dir, *platform, *wordlist)
	}
}
