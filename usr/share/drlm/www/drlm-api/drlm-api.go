package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/cgi"
	"os"
	"strings"
)

func drlmClientsService(w http.ResponseWriter, r *http.Request) {
	CGIpath := ""

	if strings.Join(os.Args[1:], "") != "" {
		CGIpath = strings.Join(os.Args[1:], "")
	} else {
		CGIpath = "/usr/share/drlm/www/cgi-bin"
	}

	path := "/"
	i := strings.Index(r.URL.Path, "/")
	r.URL.Path = r.URL.Path[i+1:]
	i = strings.Index(r.URL.Path, "/")
	r.URL.Path = r.URL.Path[i:]

	element := CGIpath + "/clients"

	var cgih = cgi.Handler{
		Path: element,
		Root: path,
	}
	cgih.ServeHTTP(w, r)
}

func drlmRootService(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "DRLM SERVER")
}

func main() {
	cert := "/etc/drlm/cert/drlm.crt"
	key := "/etc/drlm/cert/drlm.key"

	http.HandleFunc("/clients/", drlmClientsService)
	http.HandleFunc("/", drlmRootService)

	err := http.ListenAndServeTLS(":443", cert, key, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
