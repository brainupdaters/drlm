//utilities.go
package main

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"path/filepath"
	"regexp"
	"strings"

	"./models"
)

func validateHostname(h string) bool {
	valid, _ := regexp.MatchString(`^[A-z0-9\.\-]+$`, h)
	return valid
}

func check(e error) {
	if e != nil {
		logger.Println(e.Error())
	}
}

func getField(r *http.Request, index int) string {
	fields := r.Context().Value(ctxKey{}).(CtxValues).matches
	return fields[index]
}

func GetMD5Hash(text string) string {
	hasher := md5.New()
	hasher.Write([]byte(text))
	return hex.EncodeToString(hasher.Sum(nil))
}

func generateJSONResponse(object interface{}) string {

	r := models.Response{
		Version: "2.4.5",
		Result:  object,
	}

	b, _ := json.Marshal(r)
	return string(b)

}

func fileNameWithoutExtension(fileName string) string {
	return strings.TrimSuffix(fileName, filepath.Ext(fileName))
}

//////////////// DEBUG BODY /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
// buf, bodyErr := ioutil.ReadAll(r.Body)
// if bodyErr != nil {
// 	logger.Print("bodyErr ", bodyErr.Error())
// 	http.Error(w, bodyErr.Error(), http.StatusInternalServerError)
// 	return
// }

// rdr1 := ioutil.NopCloser(bytes.NewBuffer(buf))
// rdr2 := ioutil.NopCloser(bytes.NewBuffer(buf))
// logger.Printf("BODY: %q", rdr1)
// r.Body = rdr2
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
