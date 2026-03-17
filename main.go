package main

import (
	"fmt"
	"os"
	"outclash-service/cmd"
)

func main() {
	if err := cmd.MainCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
