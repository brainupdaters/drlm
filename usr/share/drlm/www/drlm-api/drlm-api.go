package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
)

func drlmClientsService(w http.ResponseWriter, r *http.Request) {

	reqToken := r.Header.Get("Authorization")
	urlPart := strings.Split(r.URL.Path, "/")
	recivedClientName := urlPart[2]

	// Check if the recived Client Name is a valid client name
	if !validateHostname(recivedClientName) {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintln(w, "invalid hostname")
		return
	}

	// Load client from database
	client := new(Client)
	client.GetByName(recivedClientName)

	// Check if recieved token is a valid token.
	if reqToken != client.Token {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusForbidden)
		fmt.Fprintln(w, "invalid token")
		return
	}

	recivedClientip, _, _ := net.SplitHostPort(r.RemoteAddr)

	if client.IP != recivedClientip {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusForbidden)
		return
	}

	if r.Method == "GET" {
		if len(urlPart) >= 5 && len(urlPart[4]) > 0 {
			if urlPart[3] == "config" {
				client.sendConfig(w, urlPart[4])
			}
		} else {
			client.sendConfig(w, "default")
		}

	} else if r.Method == "PUT" {
		if len(urlPart) >= 5 && urlPart[3] == "log" {
			f, err := os.OpenFile(configDRLM.RearLogDir+"/rear-"+recivedClientName+"."+urlPart[4]+"."+urlPart[5]+".log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
			check(err)
			defer f.Close()

			io.Copy(f, r.Body)

			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(http.StatusOK)
		}

	} else {
		fmt.Println("Method", r.Method)

		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusMethodNotAllowed)
	}

}

func drlmRootService(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "DRLM SERVER\n")
}

func main() {

	loadDRLMConfiguration()
	printDRLMConfiguration()

	http.HandleFunc("/clients/", drlmClientsService)
	http.HandleFunc("/", drlmRootService)

	err := http.ListenAndServeTLS(":443", configDRLM.Certificate, configDRLM.Key, nil)
	check(err)
}
