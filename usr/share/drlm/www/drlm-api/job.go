//jobs.go
package main

import (
	"fmt"
	"net/http"

	"./models"
	_ "github.com/mattn/go-sqlite3"
)

type Job models.Job

func (j *Job) GetAll() ([]Job, error) {
	db := GetConnection()
	q := "SELECT idjob, clients_id, ifnull(start_date,'-'), ifnull(end_date,'-'), ifnull(last_date,'-'),ifnull( next_date,'-'), repeat, enabled, config, status FROM jobs"
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
			&j.Status,
		)
		jobs = append(jobs, *j)
	}
	return jobs, nil
}

func (j *Job) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT idjob, clients_id, ifnull(start_date,'-'), ifnull(end_date,'-'), ifnull(last_date,'-'),ifnull( next_date,'-'), repeat, enabled, config, status FROM jobs WHERE idjob=?"

	err := db.QueryRow(q, id).Scan(
		&j.ID,
		&j.ClientID,
		&j.StartDate,
		&j.EndDate,
		&j.LastDate,
		&j.NextDate,
		&j.Repeat,
		&j.Enabled,
		&j.Config,
		&j.Status,
	)
	if err != nil {
		return err
	}

	return nil
}

// Get JSON of all jobs
func apiGetJobs(w http.ResponseWriter, r *http.Request) {
	response := ""

	allJobs, err := new(Job).GetAll()
	if err == nil {
		response = generateJSONResponse(allJobs)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting jobs")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected job
func apiGetJob(w http.ResponseWriter, r *http.Request) {
	receivedJobID := getField(r, 0)
	response := ""

	job := new(Job)
	err := job.GetByID(receivedJobID)
	if err == nil {
		response = generateJSONResponse(job)
	} else {
		response = generateJSONResponse("")
		logger.Println("Job", receivedJobID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}

	fmt.Fprintln(w, response)
}
