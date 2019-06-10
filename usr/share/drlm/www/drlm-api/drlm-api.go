package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

func check(e error) {
	if e != nil {
		fmt.Println(e.Error())
	}
}

func validateHostname(h string) bool {
	valid, _ := regexp.MatchString(`^[A-z0-9\.\-]+$`, h)
	return valid
}

func sendConfigFile(w http.ResponseWriter, file string) {
	if _, err := os.Stat(file); err == nil {
		f, err := ioutil.ReadFile(file) // just pass the file name
		check(err)
		w.Write(f)
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
	} else {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusNotFound)
	}
}

func drlmClientsService(w http.ResponseWriter, r *http.Request) {
	urlPart := strings.Split(r.URL.Path, "/")

	if !validateHostname(urlPart[2]) {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintln(w, "invalid hostname")
		return
	}

	clientID, err := exec.Command("/bin/bash", "-c", "VAR_DIR=\"/var/lib/drlm\"; source /usr/share/drlm/conf/default.conf; source /etc/drlm/local.conf; source /usr/share/drlm/lib/dbdrv/$DB_BACKEND-driver.sh; source /usr/share/drlm/lib/http-functions.sh; source /usr/share/drlm/lib/client-functions.sh; get_client_id_by_name "+urlPart[2]).Output()
	check(err)
	clientIDStr := strings.TrimSpace(string(clientID))

	clientIP, err := exec.Command("/bin/bash", "-c", "VAR_DIR=\"/var/lib/drlm\"; source /usr/share/drlm/conf/default.conf; source /etc/drlm/local.conf; source /usr/share/drlm/lib/dbdrv/$DB_BACKEND-driver.sh; source /usr/share/drlm/lib/http-functions.sh; source /usr/share/drlm/lib/client-functions.sh; get_client_ip "+clientIDStr).Output()
	check(err)
	clientIPStr := strings.TrimSpace(string(clientIP))

	clientConfDir, err := exec.Command("/bin/bash", "-c", "VAR_DIR=\"/var/lib/drlm\"; source /usr/share/drlm/conf/default.conf; source /etc/drlm/local.conf; echo $CLI_CONF_DIR").Output()
	check(err)
	clientConfDirStr := strings.TrimSpace(string(clientConfDir))

	rearLogDir, err := exec.Command("/bin/bash", "-c", "VAR_DIR=\"/var/lib/drlm\"; source /usr/share/drlm/conf/default.conf; source /etc/drlm/local.conf; echo $REAR_LOG_DIR").Output()
	check(err)
	rearLogDirStr := strings.TrimSpace(string(rearLogDir))

	ip, _, _ := net.SplitHostPort(r.RemoteAddr)

	if clientIPStr != ip {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusForbidden)
		return
	}

	if len(urlPart) == 3 || (len(urlPart) == 4 && urlPart[3] == "") {
		// Keep backwards compatible with previous versions of ReaR (1.17 to 2.00)
		if r.Method == "GET" {
			sendConfigFile(w, clientConfDirStr+"/"+urlPart[2]+".cfg")
		} else {
			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	} else {
		switch urlPart[3] {
		case "config":
			if r.Method == "GET" {
				if len(urlPart) == 4 || (len(urlPart) == 5 && urlPart[4] == "") {
					sendConfigFile(w, clientConfDirStr+"/"+urlPart[2]+".cfg")
				} else {
					sendConfigFile(w, clientConfDirStr+"/"+urlPart[2]+".cfg.d/"+urlPart[4]+".cfg")
				}
			} else {
				w.Header().Set("Content-Type", "text/html")
				w.WriteHeader(http.StatusMethodNotAllowed)
			}

		case "log":
			if r.Method == "PUT" {
				f, err := os.OpenFile(rearLogDirStr+"/rear-"+urlPart[2]+"."+urlPart[4]+"."+urlPart[5]+".log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
				check(err)
				defer f.Close()

				io.Copy(f, r.Body)

				w.Header().Set("Content-Type", "text/html")
				w.WriteHeader(http.StatusOK)
			} else {
				w.Header().Set("Content-Type", "text/html")
				w.WriteHeader(http.StatusMethodNotAllowed)
			}

		default:
			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(http.StatusBadRequest)
		}
	}
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
	check(err)
}
