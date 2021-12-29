//users.go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"
	_ "github.com/mattn/go-sqlite3"
)

// User is an struct of api user
type User struct {
	Username string `json:"user_name"`
	Password string `json:"user_password"`
}

// GetAll get all api users from database
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

// GetByName gets an api user from database by user name
func (u *User) GetByName(name string) error {
	db := GetConnection()
	q := "SELECT user_name, user_password	FROM users where user_name=?"

	err := db.QueryRow(q, name).Scan(
		&u.Username,
		&u.Password,
	)
	if err != nil {
		return err
	}
	return nil
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

	// Get the expected password from database
	user := new(User)
	user.GetByName(creds.Username)
	expectedPassword := user.Password

	if expectedPassword != GetMD5Hash(creds.Password) {
		logger.Println("Failed login for user: ", creds.Username)
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
		Secure:  true,
	})
}

// Remove ser session from sessions slice and send delete cookie
func userLogout(w http.ResponseWriter, r *http.Request) {
	// Get Request Cookie "session_token"
	c, err := r.Cookie("session_token")
	if err != nil {
		// If no exist token redirec to login
		signin(w, r)
		return
	}

	// Get the session from sessions with the token value
	session := Session{"", c.Value, 0}
	session, err = session.Get()
	if err != nil {
		// If there is an error fetching from sessions, redirect to login
		signin(w, r)
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

// Get JSON list off all users
func apiGetUsers(w http.ResponseWriter, r *http.Request) {
	allUsers, _ := new(User).GetAll()
	response := generateJSONResponse(allUsers)
	fmt.Fprintln(w, response)
}

// Get JSON of selected user
func apiGetUser(w http.ResponseWriter, r *http.Request) {
	receivedUserName := getField(r, 0)
	response := ""

	user := new(User)
	err := user.GetByName(receivedUserName)
	if err == nil {
		response = generateJSONResponse(user)
	} else {
		response = generateJSONResponse("")
	}

	fmt.Fprintln(w, response)
}

func apiUpdateUser(w http.ResponseWriter, r *http.Request) {

	type newCredentials struct {
		Username    string `json:"username"`
		OldPassword string `json:"old_password"`
		NewPassword string `json:"new_password"`
	}

	var newCreds newCredentials

	// Get the JSON body and decode into credentials
	err := json.NewDecoder(r.Body).Decode(&newCreds)
	if err != nil {
		// If the structure of the body is wrong, return an HTTP error
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	userToMod := getField(r, 0)

	dbuser := new(User)

	err = dbuser.GetByName(userToMod)
	if err != nil {
		logger.Println("Failed user update: " + userToMod)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	if dbuser.Password != GetMD5Hash(newCreds.OldPassword) {
		logger.Println("Failed user update: " + dbuser.Username)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	if userToMod == newCreds.Username && GetMD5Hash(newCreds.OldPassword) == GetMD5Hash(newCreds.NewPassword) {
		logger.Println("Failed user update: " + dbuser.Username)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	db := GetConnection()
	// update
	stmt, err := db.Prepare("update users set user_name=?, user_password=? where user_name=?")
	check(err)

	_, err = stmt.Exec(newCreds.Username, GetMD5Hash(newCreds.NewPassword), dbuser.Username)
	check(err)

	logger.Println("User " + userToMod + " updated")
}
