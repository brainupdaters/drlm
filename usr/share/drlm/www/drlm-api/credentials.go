// credentials.go
package main

type Credentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Version  string `json:"version"`
	Platform string `json:"platform"`
}
