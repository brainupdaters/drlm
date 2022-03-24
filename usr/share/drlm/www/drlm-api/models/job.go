package models

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

type JobResponse struct {
	Version string `json:"version"`
	Result  []Job  `json:"result"`
}
