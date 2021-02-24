//users.go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/google/uuid"
	_ "github.com/mattn/go-sqlite3"
)

type User struct {
	Username string `json:"user_name"`
	Password string `json:"user_password"`
}

func (u *User) GetAll() ([]User, error) {
	db := GetConnection()
	q := "SELECT user_name, user_password	FROM users"
	rows, err := db.Query(q)
	if err != nil {
		return []User{}, err
	}
	defer rows.Close()
	users := []User{}
	for rows.Next() {
		rows.Scan(
			&u.Username,
			&u.Password,
		)
		users = append(users, *u)
	}
	return users, nil
}

func (u *User) GetByName(name string) (User, error) {
	db := GetConnection()
	q := "SELECT user_name, user_password	FROM users where user_name=?"

	err := db.QueryRow(q, name).Scan(
		&u.Username,
		&u.Password,
	)
	if err != nil {
		return User{}, err
	}
	return *u, nil
}

func userSignin(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	// Get the JSON body and decode into credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		// If the structure of the body is wrong, return an HTTP error
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Get the expected password from our in memory map
	user := new(User)
	user.GetByName(creds.Username)
	expectedPassword := user.Password

	if expectedPassword != GetMD5Hash(creds.Password) {
		log.Println("Failed login for user: ", creds.Username)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Create a new random session token
	sessionToken := uuid.New().String()
	sessions = append(sessions, Session{creds.Username, sessionToken, time.Now().Unix()})

	// Finally, we set the client cookie for "session_token" as the session token we just generated
	// we also set an expiry time of 600 seconds, the same as the cache
	http.SetCookie(w, &http.Cookie{
		Name:    "session_token",
		Value:   sessionToken,
		Path:    "/",
		Expires: time.Now().Add(600 * time.Second),
	})
}

func userLogout(w http.ResponseWriter, r *http.Request) {
	// Get Request Cookie "session_token"
	c, err := r.Cookie("session_token")
	if err != nil {
		// If no exist token redirec to login
		login(w, r)
		return
	}

	// Get the session from sessions whit the token value
	session := Session{"", c.Value, 0}
	session, err = session.Get()
	if err != nil {
		// If there is an error fetching from sessions, redirect to login
		login(w, r)
		return
	}

	session.Delete()

	// Send updated expiration time cookie
	http.SetCookie(w, &http.Cookie{
		Name:   "session_token",
		Value:  "",
		Path:   "/",
		MaxAge: -1,
	})
}

func apiGetUsers(w http.ResponseWriter, r *http.Request) {
	allUsers, _ := new(User).GetAll()
	response := ""
	for _, c := range allUsers {
		b, _ := json.Marshal(c)
		response += string(b) + ","
	}
	if len(response) > 0 {
		response = "{\"resultList\":{\"result\":[" + response[:len(response)-1] + "]}}"
	} else {
		response = "{\"resultList\":{\"result\":[]}}"
	}

	fmt.Fprintln(w, response)
}
