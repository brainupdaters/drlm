//utilities.go
package main

import (
	"crypto/md5"
	"encoding/hex"
	"log"
	"net/http"
	"regexp"
)

func validateHostname(h string) bool {
	valid, _ := regexp.MatchString(`^[A-z0-9\.\-]+$`, h)
	return valid
}

func check(e error) {
	if e != nil {
		log.Println(e.Error())
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

//////////////// DEBUG BODY /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
// buf, bodyErr := ioutil.ReadAll(r.Body)
// if bodyErr != nil {
// 	log.Print("bodyErr ", bodyErr.Error())
// 	http.Error(w, bodyErr.Error(), http.StatusInternalServerError)
// 	return
// }

// rdr1 := ioutil.NopCloser(bytes.NewBuffer(buf))
// rdr2 := ioutil.NopCloser(bytes.NewBuffer(buf))
// log.Printf("BODY: %q", rdr1)
// r.Body = rdr2
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
