//snaps.go
package main

import (
	"fmt"
	"net/http"

	"./models"
	_ "github.com/mattn/go-sqlite3"
)

type Snap models.Snap

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

func (s *Snap) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT idbackup, idsnap, date, active, duration, size FROM snaps where idsnap=?"

	err := db.QueryRow(q, id).Scan(
		&s.IDBackup,
		&s.IDSnap,
		&s.Date,
		&s.Active,
		&s.Duration,
		&s.Size,
	)
	if err != nil {
		return err
	}

	return nil
}

// Get JSON of all snap
func apiGetSnaps(w http.ResponseWriter, r *http.Request) {
	response := ""

	allSnaps, err := new(Snap).GetAll()
	if err == nil {
		response = generateJSONResponse(allSnaps)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting snaps")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected snap
func apiGetSnap(w http.ResponseWriter, r *http.Request) {
	receivedSnapID := getField(r, 0)
	response := ""

	snap := new(Snap)
	err := snap.GetByID(receivedSnapID)
	if err == nil {
		response = generateJSONResponse(snap)
	} else {
		response = generateJSONResponse("")
		logger.Println("Snap", receivedSnapID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}

	fmt.Fprintln(w, response)
}
