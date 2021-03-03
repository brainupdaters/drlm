//client.go
package main

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

type Client struct {
	ID          int            `json:"cli_id"`
	Name        string         `json:"cli_name"`
	Mac         string         `json:"cli_mac"`
	IP          string         `json:"cli_ip"`
	NetworkName string         `json:"cli_net"`
	OS          string         `json:"cli_os"`
	ReaR        string         `json:"cli_rear"`
	Token       string         `json:"cli_token"`
	Configs     []ClientConfig `json:"cli_configs"`
}

type ClientConfig struct {
	Name    string `json:"config_name"`
	File    string `json:"config_file"`
	Content string `json:"config_content"`
}

// Get slice with all clients from database
func (c *Client) GetAll() ([]Client, error) {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients"
	rows, err := db.Query(q)
	if err != nil {
		return []Client{}, err
	}
	defer rows.Close()
	clients := []Client{}
	for rows.Next() {
		rows.Scan(
			&c.ID,
			&c.Name,
			&c.Mac,
			&c.IP,
			&c.NetworkName,
			&c.OS,
			&c.ReaR,
		)
		c.getClientToken()
		clients = append(clients, *c)
	}
	return clients, nil
}

// Get client from database by client id
func (c *Client) GetByID(id int) error {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients where idclient=?"

	err := db.QueryRow(q, id).Scan(
		&c.ID, &c.Name, &c.Mac, &c.IP, &c.NetworkName, &c.OS, &c.ReaR,
	)
	if err != nil {
		return err
	}

	if c.Name != "" {
		c.getClientToken()
		c.getClientConfigurations()
	}

	return nil
}

// Get client from database by client name
func (c *Client) GetByName(name string) error {
	db := GetConnection()
	q := "SELECT idclient, cliname, mac, ip, networks_netname, os, rear	FROM clients where cliname=?"

	err := db.QueryRow(q, name).Scan(
		&c.ID, &c.Name, &c.Mac, &c.IP, &c.NetworkName, &c.OS, &c.ReaR,
	)
	if err != nil {
		return err
	}

	if c.Name != "" {
		c.getClientToken()
		c.getClientConfigurations()
	}

	return nil
}

// Get Client Server IP
func (c *Client) getClientServerIP() (string, error) {
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

func (c *Client) getClientToken() (string, error) {
	token, err := ioutil.ReadFile("/etc/drlm/clients/" + c.Name + ".cfg.d/" + c.Name + ".token")
	if err != nil {
		log.Println("Error getting token of user ", c.Name, " err: ", err)
	}
	c.Token = string(token)

	return string(token), err
}

func (c *Client) getClientConfigurations() ([]ClientConfig, error) {
	var configs []ClientConfig

	configName := "default"
	configFile := configDRLM.CliConfigDir + "/" + c.Name + ".cfg"
	configContent, _ := c.generateConfiguration("default")

	configs = append(configs, ClientConfig{Name: configName, File: configFile, Content: configContent})

	files, err := ioutil.ReadDir(configDRLM.CliConfigDir + "/" + c.Name + ".cfg.d/")
	if err != nil {
		log.Fatal(err)
	}

	for _, f := range files {
		if filepath.Ext(f.Name()) != ".token" {
			configName := fileNameWithoutExtension(f.Name())
			configFile := configDRLM.CliConfigDir + "/" + c.Name + ".cfg.d/" + f.Name()
			configContent, _ := c.generateConfiguration(configName)
			configs = append(configs, ClientConfig{Name: configName, File: configFile, Content: configContent})
		}
	}
	c.Configs = configs

	return configs, err
}

// Generate default backup configuration
func (c *Client) generateDefaultConfig(configName string) string {

	serverIP, _ := c.getClientServerIP()

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

// Generate and send client backup configuration
func (c *Client) sendConfig(w http.ResponseWriter, configName string) {

	configuration, err := c.generateConfiguration(configName)
	if err != nil {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusNotFound)
	}

	w.Write([]byte(configuration))
	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
}

func (c *Client) generateConfiguration(configName string) (string, error) {
	// We generate the base configurations
	defaultConfig := c.generateDefaultConfig(configName)

	tmpDefaultConfig := ""
	configFileName := ""
	found := false

	if configName == "default" {
		configFileName = configDRLM.CliConfigDir + "/" + c.Name + ".cfg"
	} else {
		configFileName = configDRLM.CliConfigDir + "/" + c.Name + ".cfg.d/" + configName + ".cfg"
	}

	f, err := os.Open(configFileName)
	if err != nil {
		log.Println(err.Error())
		return "", err
	}
	defer f.Close()

	// Splits on newlines by default.
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(strings.Split(scanner.Text(), "#")[0])
		if line != "" {
			// Have a new line from config file get the var name
			varName := strings.TrimSpace(strings.Split(line, "=")[0])

			scannerDefault := bufio.NewScanner(strings.NewReader(defaultConfig))
			for scannerDefault.Scan() {
				defaultVarName := strings.TrimSpace(strings.Split(scannerDefault.Text(), "=")[0])
				// for line in default config if is diferent from var name attach to temp default config
				if varName != defaultVarName || varName[len(varName)-1] == '+' {
					tmpDefaultConfig += scannerDefault.Text() + "\n"
				} else {
					tmpDefaultConfig += strings.TrimSpace(scanner.Text()) + "\n"
					found = true
				}
			}
			// attach var line at the end com temp default config
			if !found {
				tmpDefaultConfig += strings.TrimSpace(scanner.Text()) + "\n"
			}
			defaultConfig = tmpDefaultConfig
			tmpDefaultConfig = ""
			found = false
		}
	}

	return defaultConfig, nil
}

// Return a JSON with all clients
func apiGetClients(w http.ResponseWriter, r *http.Request) {
	response := ""

	allClients, err := new(Client).GetAll()
	if err == nil {
		response = generateJSONResponse(allClients)
	} else {
		response = generateJSONResponse("")
	}

	fmt.Fprintln(w, response)
}

// Client put log Handler
func apiPutClientLogLegacy(w http.ResponseWriter, r *http.Request) {
	receivedClientName := getField(r, 0)
	receivedWorkflow := getField(r, 1)
	receivedDate := getField(r, 2)

	f, err := os.OpenFile(configDRLM.RearLogDir+"/rear-"+receivedClientName+"."+receivedWorkflow+"."+receivedDate+".log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	check(err)
	defer f.Close()
	io.Copy(f, r.Body)
	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
}

// Client get configuration Handler
func apiGetClientConfigLegacy(w http.ResponseWriter, r *http.Request) {
	receivedClientName := getField(r, 0)
	receivedConfig := ""
	if len(r.Context().Value(ctxKey{}).([]string)) > 1 {
		receivedConfig = getField(r, 1)
	}

	client := new(Client)
	client.GetByName(receivedClientName)

	if receivedConfig == "/" || receivedConfig == "" {
		client.sendConfig(w, "default")
	} else {
		client.sendConfig(w, receivedConfig)
	}
}

// Get JSON of selected user
func apiGetClient(w http.ResponseWriter, r *http.Request) {
	receivedClientName := getField(r, 0)
	response := ""

	client := new(Client)
	err := client.GetByName(receivedClientName)
	if err == nil {
		response = generateJSONResponse(client)
	} else {
		response = generateJSONResponse("")
	}

	fmt.Fprintln(w, response)
}

func apiGetClientConfigs(w http.ResponseWriter, r *http.Request) {
	receivedClientName := getField(r, 0)
	client := new(Client)
	client.GetByName(receivedClientName)
	fmt.Fprintln(w, generateJSONResponse(client.Configs))
}

func apiGetClientConfig(w http.ResponseWriter, r *http.Request) {
	receivedClientName := getField(r, 0)
	receivedClientConfig := getField(r, 1)

	client := new(Client)
	client.GetByName(receivedClientName)

	configName := "default"
	configFile := configDRLM.CliConfigDir + "/" + receivedClientName + ".cfg"
	configContent, _ := client.generateConfiguration(receivedClientConfig)

	fmt.Fprintln(w, generateJSONResponse(ClientConfig{Name: configName, File: configFile, Content: configContent}))
}
