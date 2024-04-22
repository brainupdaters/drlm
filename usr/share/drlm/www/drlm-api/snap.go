// snaps.go
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
	q := "SELECT snaps.idbackup, snaps.idsnap, snaps.date, snaps.active, snaps.duration, snaps.size, snaps.hold, policy.saved_by FROM snaps LEFT JOIN policy ON snaps.idsnap = policy.idsnap and snaps.idbackup = policy.idbackup"
	rows, err := db.Query(q)
	if err != nil {
		return []Snap{}, err
	}
	defer rows.Close()
	snaps := []Snap{}
	for rows.Next() {
		s = new(Snap)
		rows.Scan(
			&s.IDBackup,
			&s.IDSnap,
			&s.Date,
			&s.Active,
			&s.Duration,
			&s.Size,
			&s.Hold,
			&s.Saved_by,
		)
		snaps = append(snaps, *s)
	}
	return snaps, nil
}

func (s *Snap) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT snaps.idbackup, snaps.idsnap, snaps.date, snaps.active, snaps.duration, snaps.size, snaps.hold, policy.saved_by FROM snaps LEFT JOIN policy ON snaps.idsnap = policy.idsnap and snaps.idbackup = policy.idbackup WHERE snaps.idsnap=?"

	err := db.QueryRow(q, id).Scan(
		&s.IDBackup,
		&s.IDSnap,
		&s.Date,
		&s.Active,
		&s.Duration,
		&s.Size,
		&s.Hold,
		&s.Saved_by,
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
