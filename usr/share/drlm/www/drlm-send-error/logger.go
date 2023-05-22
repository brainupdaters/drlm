package main

import (
	"fmt"
	"log"
	"os"
)

var apilog *os.File
var logger *log.Logger

func init() {
	apilog, err := os.OpenFile("/var/log/drlm/drlm-send-error.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		fmt.Printf("error opening file: %v", err)
		os.Exit(1)
	}
	logger = log.New(apilog, "", log.Lshortfile|log.LstdFlags)
}
