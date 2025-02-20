package models

type Snap struct {
	IDBackup string `json:"idbackup"`
	IDSnap   string `json:"idsnap"`
	Date     string `json:"date"`
	Active   string `json:"active"`
	Duration string `json:"duration"`
	Size     string `json:"size"`
	Hold     string `json:"hold"`
	Saved_by string `json:"saved_by"`
}

type SnapResponse struct {
	Version string `json:"version"`
	Result  []Snap `json:"result"`
}
