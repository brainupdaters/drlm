//drlm-api.go
package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

func signin(w http.ResponseWriter, r *http.Request) {

	// Check if user have an active session else serve signin.html
	if r.URL.Path != "/signin" {
		http.Redirect(w, r, "/signin", http.StatusFound)
	} else {
		c, err := r.Cookie("session_token")
		if err != nil {
			// If no exist token redirec to login
			http.ServeFile(w, r, configDRLM.VarDir+"/www/signin.html")
			return
		}

		// First clean old sessions
		new(Session).CleanSessions()

		// Get the session from sessions with the token value
		session := Session{"", c.Value, 0, "", ""}
		session, err = session.Get()
		if err != nil {
			// If there is an error fetching from sessions, redirect to login
			http.ServeFile(w, r, configDRLM.VarDir+"/www/signin.html")
			return
		}

		session.Timestamp = time.Now().Unix()
		session.Update()

		// Send updated expiration time cookie
		http.SetCookie(w, &http.Cookie{
			Name:    "session_token",
			Value:   session.Token,
			Path:    "/",
			Expires: time.Now().Add(600 * time.Second),
			Secure:  true,
		})

		http.Redirect(w, r, "/", http.StatusFound)
	}
}

// Serve static content
func staticGet(w http.ResponseWriter, r *http.Request) {
	// get the absolute path to prevent directory traversal
	path, err := filepath.Abs(r.URL.Path)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	// prepend the path with the path to the static directory
	path = filepath.Join(configDRLM.VarDir+"/www", path)
	// check whether a file exists at the given path
	_, err = os.Stat(path)
	if err != nil {
		// if we got an error (that wasn't that the file doesn't exist) stating the file, return a 500 internal server error and stop
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	// otherwise, use http.FileServer to serve the static dir
	http.FileServer(http.Dir(configDRLM.VarDir+"/www")).ServeHTTP(w, r)
}

// Middleware to log requests
func middlewareLog(h http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		//logger.SetOutput(os.Stdout) // logs go to Stderr by default
		logger.Println(r.RemoteAddr, r.Method, r.URL)
		h.ServeHTTP(w, r) // call ServeHTTP on the original handler
	})
}

// Middleware to check if the recived user token is ok
// User --> API / Web Page user
func middlewareUserToken(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Get Request Cookie "session_token"
		c, err := r.Cookie("session_token")
		if err != nil {
			// If no exist token redirec to login
			signin(w, r)
			return
		}

		// First clean old sessions
		new(Session).CleanSessions()

		// Get the session from sessions with the token value
		session := Session{"", c.Value, 0, "", ""}
		session, err = session.Get()
		if err != nil {
			// If there is an error fetching from sessions, redirect to login
			signin(w, r)
			return
		}

		ctxVal := r.Context().Value(ctxKey{}).(CtxValues)
		ctxVal.version = session.Version
		ctxVal.platform = session.Platform
		ctx := context.WithValue(r.Context(), ctxKey{}, ctxVal)

		session.Timestamp = time.Now().Unix()
		session.Update()

		// Send updated expiration time cookie
		http.SetCookie(w, &http.Cookie{
			Name:    "session_token",
			Value:   session.Token,
			Path:    "/",
			Expires: time.Now().Add(600 * time.Second),
			Secure:  true,
		})

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// Middleware to check if the recived client token is ok
// Client --> DRLM client
func middlewareClientToken(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		receivedToken := r.Header.Get("Authorization")
		receivedClientName := getField(r, 0)

		// Check if the recived Client Name is a valid client name
		if !validateHostname(receivedClientName) {
			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprintln(w, "invalid hostname")
			return
		}

		// Load client from database
		client := new(Client)
		client.GetByName(receivedClientName)

		// Check if recieved token is a valid token.
		if receivedToken != client.Token {
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

		next.ServeHTTP(w, r)

	})
}

type route struct {
	method  string
	regex   *regexp.Regexp
	handler http.HandlerFunc
}

// Creating Context variables
type ctxKey struct{}
type CtxValues struct {
	matches  []string
	version  string
	platform string
}

// Http Routing
var routes = []route{
	// File server token protected
	newRoute("GET", "/", middlewareUserToken(staticGet)),
	// File server no protected
	newRoute("GET", "/((images|static|css|js)/[a-zA-Z0-9._/-]+)", staticGet),
	// Legacy API functions /////////////////////////
	newRoute("GET", "/clients/([^/]+)/config", middlewareClientToken(apiGetClientConfigLegacy)),
	newRoute("GET", "/clients/([^/]+)/config/([^/]+)", middlewareClientToken(apiGetClientConfigLegacy)),
	newRoute("PUT", "/clients/([^/]+)/log/([^/]+)/([^/]+)", middlewareClientToken(apiPutClientLogLegacy)),

	/////////////////////////////////////////////////
	// API functions ////////////////////////////////
	/////////////////////////////////////////////////

	// NETWORK /////
	newRoute("GET", "/api/networks", middlewareUserToken(apiGetNetworks)),
	newRoute("GET", "/api/networks/([^/]+)", middlewareUserToken(apiGetNetwork)),
	newRoute("GET", "/api/networks/name/([^/]+)", middlewareUserToken(apiGetNetworkByName)),

	// CLIENT /////
	// Unlike legacy functions, the new API client functions use ID client, not Cliet Name.
	newRoute("GET", "/api/clients", middlewareUserToken(apiGetClients)),
	newRoute("GET", "/api/clients/([^/]+)", middlewareUserToken(apiGetClient)),
	newRoute("GET", "/api/clients/([^/]+)/configs", middlewareUserToken(apiGetClientConfigs)),
	newRoute("GET", "/api/clients/([^/]+)/configs/([^/]+)", middlewareUserToken(apiGetClientConfig)),
	newRoute("GET", "/api/clients/([^/]+)/backups", middlewareUserToken(apiGetClientBackups)),

	// BACKUP /////
	newRoute("GET", "/api/backups", middlewareUserToken(apiGetBackups)),
	newRoute("GET", "/api/backups/([^/]+)", middlewareUserToken(apiGetBackup)),
	newRoute("GET", "/api/backups/([^/]+)/snaps", middlewareUserToken(apiGetBackupSnaps)),

	// JOBS /////
	newRoute("GET", "/api/jobs", middlewareUserToken(apiGetJobs)),
	newRoute("GET", "/api/jobs/([^/]+)", middlewareUserToken(apiGetJob)),

	// SNAPS /////
	newRoute("GET", "/api/snaps", middlewareUserToken(apiGetSnaps)),
	newRoute("GET", "/api/snaps/([^/]+)", middlewareUserToken(apiGetSnap)),

	// USERS /////
	newRoute("GET", "/api/users", middlewareUserToken(apiGetUsers)),
	newRoute("GET", "/api/users/([^/]+)", middlewareUserToken(apiGetUser)),
	newRoute("PUT", "/api/users/([^/]+)", middlewareUserToken(apiUpdateUser)),

	// SESSIONS /////
	newRoute("GET", "/api/sessions", middlewareUserToken(apiGetSessions)),
	/////////////////////////////////////////////////

	// User Control Functions ///////////////////////
	newRoute("POST", "/signin", userSignin),
	newRoute("GET", "/signin", signin),
	newRoute("POST", "/logout", middlewareUserToken(userLogout)),
}

func newRoute(method, pattern string, handler http.HandlerFunc) route {
	return route{method, regexp.MustCompile("^" + pattern + "$"), handler}
}

func Serve(w http.ResponseWriter, r *http.Request) {
	var allow []string
	for _, route := range routes {
		matches := route.regex.FindStringSubmatch(r.URL.Path)
		if len(matches) > 0 {
			if r.Method != route.method {
				allow = append(allow, route.method)
				continue
			}

			v := CtxValues{
				matches[1:],
				"",
				"",
			}
			ctx := context.WithValue(r.Context(), ctxKey{}, v)

			route.handler(w, r.WithContext(ctx))
			return
		}
	}

	if len(allow) > 0 {
		w.Header().Set("Allow", strings.Join(allow, ", "))
		http.Error(w, "405 method not allowed", http.StatusMethodNotAllowed)
		return
	}

	//http.NotFound(w, r)
	w.WriteHeader(http.StatusNotFound)
}

func main() {
	// Load DRLM configuration files
	loadDRLMConfiguration()
	// Show DRLM configuration files
	printDRLMConfiguration()
	// Update API User
	updateDefaultAPIUser()

	// Run HTTPS server with middlewareLog
	logger.Fatal(http.ListenAndServeTLS(":443", configDRLM.Certificate, configDRLM.Key, http.HandlerFunc(middlewareLog(Serve))))
}
