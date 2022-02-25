//www/drlm-proxy/drlm-proxy.go

package main

import (
	"io"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	// Load DRLM PROXY configuration vars
	loadDRLMProxyConfiguration()
	// Show DRLM PROXY configuratio vars
	printDRLMProxyConfiguration()

	rtr := mux.NewRouter()
	rtr.HandleFunc("/Rear/{distro}/{arch}/{package}", remotepkg)
	http.ListenAndServe(":80", rtr)
}

func remotepkg(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	nom_paket := r.URL.Path

	logger.Println(r.RemoteAddr, ": request package ", nom_paket)
	logger.Println(r.RemoteAddr, ": redirected from", configDRLMProxy.CurrenturlURLBase, "to", configDRLMProxy.RedirectURL)

	resp, err := http.Get(configDRLMProxy.RedirectURL + nom_paket)
	if err != nil {
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		logger.Println(r.RemoteAddr, ": requested package not found!")
		return
	} else {
		logger.Println(r.RemoteAddr, ": sending requested package")
	}

	w.Header().Set("Expires", "0")
	w.Header().Set("Content-Transfer-Encoding", "binary")
	w.Header().Set("Content-Control", "private, no-transform, no-store, must-revalidate")
	w.Header().Set("Content-Disposition", "attachment; filename="+vars["package"])

	io.Copy(w, resp.Body)
}
