package models

type Network struct {
	ID        string `json:"idnetwork"`
	NetworkIP string `json:"netip"`
	Mask      string `json:"mask"`
	Gateway   string `json:"gw"`
	Domain    string `json:"domain"`
	Dns       string `json:"dns"`
	Broadcast string `json:"broadcast"`
	ServerIP  string `json:"serverip"`
	Name      string `json:"netname"`
	Status    string `json:"active"`
	Interface string `json:"interface"`
}

type NetworkResponse struct {
	Version string    `json:"version"`
	Result  []Network `json:"result"`
}
