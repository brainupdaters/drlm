//network.go
package main

import (
	"fmt"
	"net/http"

	"./models"
	_ "github.com/mattn/go-sqlite3"
)

type Network models.Network

func (n *Network) GetAll() ([]Network, error) {
	db := GetConnection()
	q := "SELECT idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname, active, interface FROM networks"
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
			&n.Status,
			&n.Interface,
		)
		networks = append(networks, *n)
	}
	return networks, nil
}

func (n *Network) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname, active, interface FROM networks WHERE idnetwork=?"

	err := db.QueryRow(q, id).Scan(
		&n.ID,
		&n.NetworkIP,
		&n.Mask,
		&n.Gateway,
		&n.Domain,
		&n.Dns,
		&n.Broadcast,
		&n.ServerIP,
		&n.Name,
		&n.Status,
		&n.Interface,
	)
	if err != nil {
		return err
	}

	return nil
}

func (n *Network) GetByName(name string) error {
	db := GetConnection()
	q := "SELECT idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname, active, interface FROM networks WHERE netname=?"

	err := db.QueryRow(q, name).Scan(
		&n.ID,
		&n.NetworkIP,
		&n.Mask,
		&n.Gateway,
		&n.Domain,
		&n.Dns,
		&n.Broadcast,
		&n.ServerIP,
		&n.Name,
		&n.Status,
		&n.Interface,
	)
	if err != nil {
		return err
	}

	return nil
}

// Get JSON of all networks
func apiGetNetworks(w http.ResponseWriter, r *http.Request) {
	response := ""

	allNetworks, err := new(Network).GetAll()
	if err == nil {
		response = generateJSONResponse(allNetworks)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting networks")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected network
func apiGetNetwork(w http.ResponseWriter, r *http.Request) {
	receivedNetworkID := getField(r, 0)
	response := ""

	network := new(Network)
	err := network.GetByID(receivedNetworkID)
	if err == nil {
		response = generateJSONResponse(network)
	} else {
		response = generateJSONResponse("")
		logger.Println("Network", receivedNetworkID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}

	fmt.Fprintln(w, response)
}

// Get JSON of selected network
func apiGetNetworkByName(w http.ResponseWriter, r *http.Request) {
	receivedNetworkName := getField(r, 0)
	response := ""

	network := new(Network)
	err := network.GetByName(receivedNetworkName)
	if err == nil {
		response = generateJSONResponse(network)
	} else {
		response = generateJSONResponse("")
		logger.Println("Network", receivedNetworkName, "not found")
		w.WriteHeader(http.StatusNotFound)
	}

	fmt.Fprintln(w, response)
}
