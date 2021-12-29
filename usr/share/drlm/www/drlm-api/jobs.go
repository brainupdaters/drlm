//jobs.go
package main

import (
	"fmt"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

type Job struct {
	ID        string `json:"idjob"`
	ClientID  string `json:"clients_id"`
	StartDate string `json:"start_date"`
	EndDate   string `json:"end_date"`
	LastDate  string `json:"last_date"`
	NextDate  string `json:"next_date"`
	Repeat    string `json:"repeat"`
	Enabled   string `json:"enabled"`
	Config    string `json:"config"`
}

func (j *Job) GetAll() ([]Job, error) {
	db := GetConnection()
	q := "SELECT idjob, clients_id, ifnull(start_date,'-'), ifnull(end_date,'-'), ifnull(last_date,'-'),ifnull( next_date,'-'), repeat, enabled, config FROM jobs"
	rows, err := db.Query(q)
	if err != nil {
		return []Job{}, err
	}
	defer rows.Close()
	jobs := []Job{}
	for rows.Next() {
		rows.Scan(
			&j.ID,
			&j.ClientID,
			&j.StartDate,
			&j.EndDate,
			&j.LastDate,
			&j.NextDate,
			&j.Repeat,
			&j.Enabled,
			&j.Config,
		)
		jobs = append(jobs, *j)
	}
	return jobs, nil
}

func apiGetJobs(w http.ResponseWriter, r *http.Request) {
	allJobs, _ := new(Job).GetAll()
	response := generateJSONResponse(allJobs)
	fmt.Fprintln(w, response)
}
