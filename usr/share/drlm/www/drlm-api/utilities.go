package main

import (
	"fmt"
	"regexp"
)

func validateHostname(h string) bool {
	valid, _ := regexp.MatchString(`^[A-z0-9\.\-]+$`, h)
	return valid
}

func check(e error) {
	if e != nil {
		fmt.Println(e.Error())
	}
}
