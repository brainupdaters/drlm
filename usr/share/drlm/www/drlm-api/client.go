//client.go
package main

import (
	_ "github.com/mattn/go-sqlite3"
)

type Client struct {
	ID          int    `json:"cli_id"`
	Name        string `json:"cli_name"`
	Mac         string `json:"cli_mac"`
	IP          string `json:"cli_ip"`
	NetworkName string `json:"cli_net"`
	OS          string `json:"cli_os"`
	ReaR        string `json:"cli_rear"`
}

func (c *Client) GetAll() ([]Client, error) {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients"
	// Ejecutamos la query
	rows, err := db.Query(q)
	if err != nil {
		return []Client{}, err
	}
	// Cerramos el recurso
	defer rows.Close()
	// Declaramos un slice de notas para que almacene las notas que retorna la petición.
	clients := []Client{}
	// El método Next retorna un bool, mientras sea true indicará que existe un valor siguiente para leer.
	for rows.Next() {
		// Escaneamos el valor actual de la fila e insertamos el retorno en los correspondientes campos de la nota.
		rows.Scan(
			&c.ID,
			&c.Name,
			&c.Mac,
			&c.IP,
			&c.NetworkName,
			&c.OS,
			&c.ReaR,
		)
		// Añadimos cada nueva nota al slice de clientes que declaramos antes.
		clients = append(clients, *c)
	}
	return clients, nil
}

func (c *Client) GetByID(id int) (Client, error) {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients where idclient=?"

	err := db.QueryRow(q, id).Scan(
		&c.ID, &c.Name, &c.Mac, &c.IP, &c.NetworkName, &c.OS, &c.ReaR,
	)
	if err != nil {
		return Client{}, err
	}

	return *c, nil
}

func (c *Client) GetByName(name string) (Client, error) {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients where cliname=?"

	err := db.QueryRow(q, name).Scan(
		&c.ID, &c.Name, &c.Mac, &c.IP, &c.NetworkName, &c.OS, &c.ReaR,
	)
	if err != nil {
		return Client{}, err
	}

	return *c, nil
}

func (c *Client) GetServerIPByName() (string, error) {
	db := GetConnection()
	q := "SELECT networks.serverip FROM networks, clients where networks.netname = clients.networks_netname and clients.cliname=?"

	serverIP := ""
	err := db.QueryRow(q, c.Name).Scan(
		&serverIP,
	)
	if err != nil {
		return serverIP, err
	}
	return serverIP, nil
}

func (c *Client) generateDefaultConfig(configName string) string {

	serverIP, _ := c.GetServerIPByName()

	clientConfig := "CLI_NAME=" + c.Name + "\n"
	clientConfig += "SRV_NET_IP=" + serverIP + "\n"
	clientConfig += "OUTPUT=PXE\n"
	clientConfig += "OUTPUT_PREFIX=$OUTPUT\n"
	clientConfig += "OUTPUT_PREFIX_PXE=$CLI_NAME/" + configName + "/$OUTPUT\n"
	clientConfig += "OUTPUT_URL=nfs://$SRV_NET_IP/var/lib/drlm/store/$CLI_NAME/" + configName + "\n"
	clientConfig += "BACKUP=NETFS\n"
	clientConfig += "NETFS_PREFIX=BKP\n"
	clientConfig += "BACKUP_URL=nfs://$SRV_NET_IP/var/lib/drlm/store/$CLI_NAME/" + configName + "\n"
	clientConfig += "SSH_ROOT_PASSWORD=drlm\n"

	return clientConfig
}
