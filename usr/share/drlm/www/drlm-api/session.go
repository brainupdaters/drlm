// session.go
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"
)

type Session struct {
	Username  string `json:"username"`
	Token     string `json:"token"`
	Timestamp int64  `json:"timestamp"`
}

var sessions []Session

func (s *Session) Get() (Session, error) {
	for _, session := range sessions {
		if s.Token != "" {
			if session.Token == s.Token {
				s.Username = session.Username
				s.Token = session.Token
				s.Timestamp = session.Timestamp
				return *s, nil
			}
		}
	}
	return Session{}, errors.New("session not found")
}

func (s *Session) Update() (Session, error) {
	if s.Token == "" {
		return *s, errors.New("token not found")
	}
	if s.Timestamp == 0 {
		return *s, errors.New("timestamp not found")
	}

	for index, session := range sessions {
		if session.Token == s.Token {
			sessions[index].Timestamp = s.Timestamp
			break
		}
	}
	return *s, nil
}

func (s *Session) TimeLeft() int64 {
	if (s.Timestamp + 600) > time.Now().Unix() {
		return (s.Timestamp + 600) - time.Now().Unix()
	} else {
		return 0
	}
}

func (s *Session) CleanSessions() {
	var tmpSessions []Session

	for _, session := range sessions {
		if (session.Timestamp + 600) > time.Now().Unix() {
			tmpSessions = append(tmpSessions, session)
		}
	}

	sessions = tmpSessions
}

func (s *Session) Delete() {
	delindex := 0

	for index, session := range sessions {
		if session.Token == s.Token {
			delindex = index
			break
		}
	}

	sessions[delindex] = sessions[len(sessions)-1]
	sessions[len(sessions)-1] = Session{}
	sessions = sessions[:len(sessions)-1]
}

func apiGetSessions(w http.ResponseWriter, r *http.Request) {
	response := ""
	for _, s := range sessions {
		b, _ := json.Marshal(s)
		response += string(b) + ","
	}
	if len(response) > 0 {
		response = "{\"resultList\":{\"result\":[" + response[:len(response)-1] + "]}}"
	} else {
		response = "{\"resultList\":{\"result\":[]}}"
	}

	fmt.Fprintln(w, response)
}
