// connection.go
package main

import "database/sql"

// Database pointer
var db *sql.DB

func GetConnection() *sql.DB {

	if db != nil {
		return db
	}

	var err error

	// Database file connection
	db, err = sql.Open("sqlite3", configDRLM.SqliteFile)
	if err != nil {
		panic(err)
	}

	return db
}
