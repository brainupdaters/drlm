//snaps.go
package main

import (
	"fmt"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

type Snap struct {
	IDBackup string `json:"idbackup"`
	IDSnap   string `json:"idsnap"`
	Date     string `json:"date"`
	Active   string `json:"active"`
	Duration string `json:"duration"`
	Size     string `json:"size"`
}

func (s *Snap) GetAll() ([]Snap, error) {
	db := GetConnection()
	q := "SELECT idbackup, idsnap, date, active, duration, size FROM snaps"
	rows, err := db.Query(q)
	if err != nil {
		return []Snap{}, err
	}
	defer rows.Close()
	snaps := []Snap{}
	for rows.Next() {
		rows.Scan(
			&s.IDBackup,
			&s.IDSnap,
			&s.Date,
			&s.Active,
			&s.Duration,
			&s.Size,
		)
		snaps = append(snaps, *s)
	}
	return snaps, nil
}

func apiGetSnaps(w http.ResponseWriter, r *http.Request) {
	allSnaps, _ := new(Snap).GetAll()
	response := generateJSONResponse(allSnaps)
	fmt.Fprintln(w, response)
}
