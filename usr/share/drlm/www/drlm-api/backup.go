//backup.go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

type Backup struct {
	ID       string `json:"idbackup"`
	Client   string `json:"clients_id"`
	DR       string `json:"drfile"`
	Active   string `json:"active"`
	Duration string `json:"duration"`
	Config   string `json:"config"`
	PXE      string `json:"PXE"`
	Type     string `json:"type"`
	Date     string `json:"date"`
}

func (b *Backup) GetAll() ([]Backup, error) {
	db := GetConnection()
	q := "SELECT idbackup, clients_id, drfile, active, duration, config, PXE, type, date FROM backups"
	rows, err := db.Query(q)
	if err != nil {
		return []Backup{}, err
	}
	defer rows.Close()
	backups := []Backup{}
	for rows.Next() {
		rows.Scan(
			&b.ID,
			&b.Client,
			&b.DR,
			&b.Active,
			&b.Duration,
			&b.Config,
			&b.PXE,
			&b.Type,
			&b.Date,
		)
		backups = append(backups, *b)
	}
	return backups, nil
}

func apiGetBackups(w http.ResponseWriter, r *http.Request) {
	allBackups, _ := new(Backup).GetAll()
	response := ""
	for _, c := range allBackups {
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
