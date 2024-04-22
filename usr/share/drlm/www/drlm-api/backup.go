// backup.go
package main

import (
	"fmt"
	"net/http"

	"./models"
	_ "github.com/mattn/go-sqlite3"
)

type Backup models.Backup

// Get all backup from database
func (b *Backup) GetAll() ([]Backup, error) {
	db := GetConnection()
	q := "SELECT backups.idbackup, backups.clients_id, backups.drfile, backups.active, backups.duration, backups.size, backups.config, backups.PXE, backups.type, backups.protocol, backups.date, backups.encrypted, backups.encryp_pass, backups.hold, policy.saved_by FROM backups LEFT JOIN policy ON backups.idbackup = policy.idbackup and policy.idsnap = ''"
	rows, err := db.Query(q)
	if err != nil {
		return []Backup{}, err
	}
	defer rows.Close()

	backups := []Backup{}

	for rows.Next() {
		b := new(Backup)
		rows.Scan(
			&b.ID,
			&b.Client,
			&b.DR,
			&b.Active,
			&b.Duration,
			&b.Size,
			&b.Config,
			&b.PXE,
			&b.Type,
			&b.Protocol,
			&b.Date,
			&b.Encrypted,
			&b.EncrypPass,
			&b.Hold,
			&b.Saved_by,
		)
		backups = append(backups, *b)
	}
	return backups, nil
}

// Get backup from database by backup id
func (b *Backup) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT backups.idbackup, backups.clients_id, backups.drfile, backups.active, backups.duration, backups.size, backups.config, backups.PXE, backups.type, backups.protocol, backups.date, backups.encrypted, backups.encryp_pass, backups.hold, policy.saved_by FROM backups LEFT JOIN policy ON backups.idbackup = policy.idbackup and policy.idsnap = '' WHERE backups.idbackup=?"

	err := db.QueryRow(q, id).Scan(
		&b.ID,
		&b.Client,
		&b.DR,
		&b.Active,
		&b.Duration,
		&b.Size,
		&b.Config,
		&b.PXE,
		&b.Type,
		&b.Protocol,
		&b.Date,
		&b.Encrypted,
		&b.EncrypPass,
		&b.Hold,
		&b.Saved_by,
	)
	if err != nil {
		return err
	}

	return nil
}

// Get all snaps from database
func (b *Backup) GetSnaps() ([]Snap, error) {
	db := GetConnection()
	q := "SELECT snaps.idbackup, snaps.idsnap, snaps.date, snaps.active, snaps.duration, snaps.size, snaps.hold, policy.saved_by FROM snaps LEFT JOIN policy ON snaps.idsnap = policy.idsnap WHERE snaps.idbackup=?"
	rows, err := db.Query(q, b.ID)
	if err != nil {
		return []Snap{}, err
	}
	defer rows.Close()

	snaps := []Snap{}

	for rows.Next() {
		s := new(Snap)
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

// Get JSON of all backup
func apiGetBackups(w http.ResponseWriter, r *http.Request) {
	response := ""

	allBackups, err := new(Backup).GetAll()
	if err == nil {
		response = generateJSONResponse(allBackups)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting backups")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected backup
func apiGetBackup(w http.ResponseWriter, r *http.Request) {
	receivedBackupID := getField(r, 0)
	response := ""

	backup := new(Backup)
	err := backup.GetByID(receivedBackupID)
	if err == nil {
		response = generateJSONResponse(backup)
	} else {
		response = generateJSONResponse("")
		logger.Println("Backup", receivedBackupID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected backup snaps
func apiGetBackupSnaps(w http.ResponseWriter, r *http.Request) {
	receivedBackupID := getField(r, 0)

	backup := new(Backup)
	err := backup.GetByID(receivedBackupID)
	if err != nil {
		logger.Println("Backup", receivedBackupID, "not found")
		w.WriteHeader(http.StatusNotFound)
		return
	}

	response := ""
	backupSnaps, err := backup.GetSnaps()

	if err == nil {
		response = generateJSONResponse(backupSnaps)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting snaps")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}
