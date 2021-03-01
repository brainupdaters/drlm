//network.go
package main

import (
	"fmt"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

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
}

func (n *Network) GetAll() ([]Network, error) {
	db := GetConnection()
	q := "SELECT idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname FROM networks"
	rows, err := db.Query(q)
	if err != nil {
		return []Network{}, err
	}
	defer rows.Close()
	networks := []Network{}
	for rows.Next() {
		rows.Scan(
			&n.ID,
			&n.NetworkIP,
			&n.Mask,
			&n.Gateway,
			&n.Domain,
			&n.Dns,
			&n.Broadcast,
			&n.ServerIP,
			&n.Name,
		)
		networks = append(networks, *n)
	}
	return networks, nil
}

func apiGetNetworks(w http.ResponseWriter, r *http.Request) {
	allNetworks, _ := new(Network).GetAll()
	response := generateJSONResponse(allNetworks)
	fmt.Fprintln(w, response)
}
