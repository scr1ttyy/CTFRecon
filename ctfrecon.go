package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	// SET FLAGS
	ip := flag.String("u", "", "IP Address (Required)")
	dir := flag.String("d", "", "Name of directory to be created. (Required)")
	wordlist := flag.String("w", "test.txt", "Wordlist to use for Directory Busting. (Required)")
	flag.Parse()

	// COMMAND LINE ARGUMENTS CHECK
	if len(os.Args) != 4 {
		flag.PrintDefaults()
		os.Exit(1)
	}

	// TEST OUTPUT
	fmt.Printf("IP:%s\nDIR:%s\nWORDLIST:%s\n", *ip, *dir, *wordlist)

}
