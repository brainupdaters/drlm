package models

type Client struct {
	ID          string         `json:"cli_id"`
	Name        string         `json:"cli_name"`
	Mac         string         `json:"cli_mac"`
	IP          string         `json:"cli_ip"`
	NetworkName string         `json:"cli_net"`
	OS          string         `json:"cli_os"`
	ReaR        string         `json:"cli_rear"`
	VIP         string         `json:"cli_vip"`
	Token       string         `json:"cli_token"`
	Configs     []ClientConfig `json:"cli_configs"`
}

type ClientResponse struct {
	Version string   `json:"version"`
	Result  []Client `json:"result"`
}

type ClientConfig struct {
	Name    string `json:"config_name"`
	File    string `json:"config_file"`
	Content string `json:"config_content"`
}

type ClientConfigResponse struct {
	Version string         `json:"version"`
	Result  []ClientConfig `json:"result"`
}
