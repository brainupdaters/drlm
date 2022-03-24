package models

type Response struct {
	Version string      `json:"version"`
	Result  interface{} `json:"result"`
}
