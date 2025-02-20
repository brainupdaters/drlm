package models

type Backup struct {
	ID         string `json:"idbackup"`
	Client     string `json:"clients_id"`
	DR         string `json:"drfile"`
	Active     string `json:"active"`
	Duration   string `json:"duration"`
	Size       string `json:"size"`
	Config     string `json:"config"`
	PXE        string `json:"PXE"`
	Type       string `json:"type"`
	Protocol   string `json:"protocol"`
	Date       string `json:"date"`
	Encrypted  string `json:"encrypted"`
	EncrypPass string `json:"encryppass"`
	Hold       string `json:"hold"`
	Saved_by   string `json:"saved_by"`
}

type BackupResponse struct {
	Version string   `json:"version"`
	Result  []Backup `json:"result"`
}
