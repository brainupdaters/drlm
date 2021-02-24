//utilities.go
package main

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"net/http"
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

func getField(r *http.Request, index int) string {
	fields := r.Context().Value(ctxKey{}).([]string)
	return fields[index]
}

func GetMD5Hash(text string) string {
	hasher := md5.New()
	hasher.Write([]byte(text))
	return hex.EncodeToString(hasher.Sum(nil))
}
