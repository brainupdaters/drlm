// client.go
package main

import (
	"bufio"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"./models"
	_ "github.com/mattn/go-sqlite3"
)

type Client models.Client
type ClientConfig = models.ClientConfig

// Get slice with all clients from database
func (c *Client) GetAll() ([]Client, error) {
	db := GetConnection()
	q := "SELECT clients.idclient, clients.cliname, clients.mac, clients.ip, clients.networks_netname, clients.os, clients.rear, (select GROUP_CONCAT( vipclients.idclient, ',') from vipclients WHERE vipclients.idvipclient=clients.idclient) as vip FROM clients"
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
			&c.VIP,
		)
		c.getClientToken()
		c.getClientConfigurations()
		clients = append(clients, *c)
	}
	return clients, nil
}

// Get client from database by client id
func (c *Client) GetByID(id string) error {
	db := GetConnection()
	q := "SELECT clients.idclient," +
		"clients.cliname, " +
		"clients.mac, " +
		"clients.ip, " +
		"clients.networks_netname, " +
		"clients.os, " +
		"clients.rear, " +
		"(select GROUP_CONCAT(vipclients.idclient, ',') from vipclients WHERE vipclients.idvipclient = clients.idclient) as vip " +
		"FROM clients " +
		"WHERE clients.idclient=?"

	db.QueryRow(q, id).Scan(
		&c.ID,
		&c.Name,
		&c.Mac,
		&c.IP,
		&c.NetworkName,
		&c.OS,
		&c.ReaR,
		&c.VIP,
	)

	if c.Name != "" {
		c.getClientToken()
		c.getClientConfigurations()
	} else {
		return fmt.Errorf("Client ID " + id + " not found")
	}

	return nil
}

// Get client from database by client name
func (c *Client) GetByName(name string) error {
	db := GetConnection()
	q := "SELECT clients.idclient, clients.cliname, clients.mac, clients.ip, clients.networks_netname, clients.os, clients.rear, (select GROUP_CONCAT( vipclients.idclient, ',') from vipclients WHERE vipclients.idvipclient=clients.idclient) as vip FROM clients where clients.cliname=?"

	db.QueryRow(q, name).Scan(
		&c.ID,
		&c.Name,
		&c.Mac,
		&c.IP,
		&c.NetworkName,
		&c.OS,
		&c.ReaR,
		&c.VIP,
	)

	if c.Name != "" {
		c.getClientToken()
		c.getClientConfigurations()
	} else {
		return fmt.Errorf("Client Name " + name + " not found")
	}

	return nil
}

// Get backup from database by client id
func (c *Client) GetBackups() ([]Backup, error) {
	db := GetConnection()
	q := "SELECT idbackup, clients_id, drfile, active, duration, size, config, PXE, type, protocol, date, encrypted, encryp_pass, hold FROM backups where clients_id=?"
	rows, err := db.Query(q, c.ID)
	if err != nil {
		return []Backup{}, err
	}
	defer rows.Close()

	backups := []Backup{}

	for rows.Next() {
		b := new(Backup)
		rows.Scan(
			&b.ID,
			&b.Client,
			&b.DR,
			&b.Active,
			&b.Duration,
			&b.Size,
			&b.Config,
			&b.PXE,
			&b.Type,
			&b.Protocol,
			&b.Date,
			&b.Encrypted,
			&b.EncrypPass,
			&b.Hold,
		)
		backups = append(backups, *b)
	}
	return backups, nil
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

// Get Client Name by IP
func (c *Client) getClientNameByIP(ip string) (string, error) {
	db := GetConnection()
	q := "SELECT clients.cliname FROM clients where clients.ip=?"

	clientName := ""
	err := db.QueryRow(q, ip).Scan(
		&clientName,
	)
	if err != nil {
		return clientName, err
	}
	return clientName, nil
}

// Get Client Token
func (c *Client) getClientToken() (string, error) {
	token, err := os.ReadFile("/etc/drlm/clients/" + c.Name + ".token")
	if err != nil {
		logger.Println("Error getting token of user ", c.Name, " err: ", err)
	}
	c.Token = string(token)

	return string(token), err
}

func (c *Client) getClientVipTokens() ([]string, error) {
	db := GetConnection()
	q := "SELECT clients.cliname FROM clients, vipclients WHERE clients.idclient=vipclients.idclient AND vipclients.idvipclient=?"
	rows, err := db.Query(q, c.ID)
	if err != nil {
		return []string{}, err
	}
	defer rows.Close()

	vipTokens := []string{}

	for rows.Next() {
		var cliname string
		rows.Scan(&cliname)

		token, err := os.ReadFile("/etc/drlm/clients/" + cliname + ".token")
		if err != nil {
			logger.Println("Error getting token of user ", cliname, " err: ", err)
		}
		vipTokens = append(vipTokens, string(token))
	}

	return vipTokens, nil
}

func (c *Client) getClientVipIPs() ([]string, error) {
	db := GetConnection()
	q := "SELECT clients.ip FROM clients, vipclients WHERE clients.idclient=vipclients.idclient AND vipclients.idvipclient=?"
	rows, err := db.Query(q, c.ID)
	if err != nil {
		return []string{}, err
	}
	defer rows.Close()

	vipIPs := []string{}

	for rows.Next() {
		var ip string
		rows.Scan(&ip)
		vipIPs = append(vipIPs, ip)
	}

	return vipIPs, nil
}

// Get Client Configurations
func (c *Client) getClientConfigurations() ([]ClientConfig, error) {
	var configs []ClientConfig

	configName := "default"
	configFile := configDRLM.CliConfigDir + "/" + c.Name + ".cfg"
	configContent, _ := c.generateConfiguration("default")

	configs = append(configs, ClientConfig{Name: configName, File: configFile, Content: configContent})

	files, err := os.ReadDir(configDRLM.CliConfigDir + "/" + c.Name + ".cfg.d/")
	if err != nil {
		logger.Fatal(err)
	}

	for _, f := range files {
		if filepath.Ext(f.Name()) == ".cfg" {
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

	// Generate configFileName to get the backup type, protocol and program
	configFileName := ""
	if configName == "default" {
		configFileName = configDRLM.CliConfigDir + "/" + c.Name + ".cfg"
	} else {
		configFileName = configDRLM.CliConfigDir + "/" + c.Name + ".cfg.d/" + configName + ".cfg"
	}

	configFile, err := os.Open(configFileName)
	if err != nil {
		logger.Println(err.Error())
		// TODO what to do if returned error?
		return ""
	}
	defer configFile.Close()

	drlmBkpType := ""
	drlmBkpProt := ""
	drlmBkpSecProt := ""
	drlmBkpProg := ""

	// Splits on newlines by default.
	scanner := bufio.NewScanner(configFile)
	for scanner.Scan() {
		line := strings.TrimSpace(strings.Split(scanner.Text(), "#")[0])
		if line != "" {
			// Have a new line from config file get the var name
			varName := strings.TrimSpace(strings.Split(line, "=")[0])
			// And get var value if exist
			varValue := ""
			if len(strings.Split(line, "=")) > 1 {
				varValue = strings.TrimSpace(strings.Split(line, "=")[1])
			}
			// if varName is like DRLM_BKP_* get its value
			if varName == "DRLM_BKP_TYPE" {
				drlmBkpType = varValue
			} else if varName == "DRLM_BKP_PROT" {
				drlmBkpProt = varValue
			} else if varName == "DRLM_BKP_SEC_PROT" {
				drlmBkpSecProt = varValue
			} else if varName == "DRLM_BKP_PROG" {
				drlmBkpProg = varValue
			} else if varName == "OUTPUT" {
				//Legacy mode
				drlmBkpType = "PXE"
				drlmBkpProt = "NETFS"
				drlmBkpProg = "TAR"
			}
		}
	}

	serverIP, _ := c.getClientServerIP()

	clientConfig := ""
	/////////////
	// ISO
	/////////////
	if drlmBkpType == "ISO" || drlmBkpType == "\"ISO\"" || drlmBkpType == "" {
		if drlmBkpProt == "RSYNC" || drlmBkpProt == "\"RSYNC\"" || drlmBkpProt == "" {
			clientConfig = "export RSYNC_PASSWORD=$(cat /etc/rear/drlm.token)\n"
			clientConfig += "OUTPUT=ISO\n"
			clientConfig += "OUTPUT_PREFIX=ISO\n"
			clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
			clientConfig += "BACKUP=RSYNC\n"
			clientConfig += "RSYNC_PREFIX=\n"
			clientConfig += "BACKUP_URL=rsync://" + c.Name + "@" + serverIP + "::/" + c.Name + "_" + configName + "\n"
			clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			if drlmBkpSecProt == "yes" || drlmBkpSecProt == "\"yes\"" || drlmBkpSecProt == "" {
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( '-e stunnel /etc/rear/stunnel/drlm.conf' )\n"
				clientConfig += "RSYNC_PORT=874\n"
				clientConfig += "REQUIRED_PROGS+=( 'stunnel' )\n"
			}
		} else if drlmBkpProt == "NETFS" || drlmBkpProt == "\"NETFS\"" {
			if drlmBkpProg == "TAR" || drlmBkpProg == "\"TAR\"" || drlmBkpProg == "" {
				clientConfig = "OUTPUT=ISO\n"
				clientConfig += "OUTPUT_PREFIX=ISO\n"
				clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "NETFS_PREFIX=backup\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
			} else if drlmBkpProg == "RSYNC" || drlmBkpProg == "\"RSYNC\"" {
				clientConfig = "OUTPUT=ISO\n"
				clientConfig += "OUTPUT_PREFIX=\n"
				clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "BACKUP_PROG=rsync\n"
				clientConfig += "NETFS_PREFIX=\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			}
		}
		////////////////
		// ISO _FULL
		////////////////
	} else if drlmBkpType == "ISO_FULL" || drlmBkpType == "\"ISO_FULL\"" {
		clientConfig = "OUTPUT=ISO\n"
		clientConfig += "OUTPUT_PREFIX=\n"
		clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
		clientConfig += "OUTPUT_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
		clientConfig += "BACKUP=NETFS\n"
		clientConfig += "BACKUP_URL=iso://backup\n"
		//////////////////
		// ISO_FULL_TMP
		//////////////////
	} else if drlmBkpType == "ISO_FULL_TMP" || drlmBkpType == "\"ISO_FULL_TMP\"" {
		clientConfig = "export TMPDIR=/tmp/drlm\n"
		clientConfig += "OUTPUT=ISO\n"
		clientConfig += "OUTPUT_PREFIX=\n"
		clientConfig += "ISO_DIR=/tmp/drlm\n"
		clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
		clientConfig += "OUTPUT_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
		clientConfig += "BACKUP=NETFS\n"
		clientConfig += "BACKUP_URL=iso://backup\n"
		/////////////
		// PXE
		/////////////
	} else if drlmBkpType == "PXE" || drlmBkpType == "\"PXE\"" {
		if drlmBkpProt == "RSYNC" || drlmBkpProt == "\"RSYNC\"" || drlmBkpProt == "" {
			clientConfig = "export RSYNC_PASSWORD=$(cat /etc/rear/drlm.token)\n"
			clientConfig += "OUTPUT=PXE\n"
			clientConfig += "OUTPUT_PREFIX=PXE\n"
			clientConfig += "OUTPUT_PREFIX_PXE=" + c.Name + "/" + configName + "/PXE\n"
			clientConfig += "OUTPUT_URL=rsync://" + c.Name + "@" + serverIP + "::/" + c.Name + "_" + configName + "\n"
			clientConfig += "BACKUP=RSYNC\n"
			clientConfig += "RSYNC_PREFIX=\n"
			clientConfig += "BACKUP_URL=rsync://" + c.Name + "@" + serverIP + "::/" + c.Name + "_" + configName + "\n"
			clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			if drlmBkpSecProt == "yes" || drlmBkpSecProt == "\"yes\"" || drlmBkpSecProt == "" {
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( '-e stunnel /etc/rear/stunnel/drlm.conf' )\n"
				clientConfig += "RSYNC_PORT=874\n"
				clientConfig += "REQUIRED_PROGS+=( 'stunnel' )\n"
			}
		} else if drlmBkpProt == "NETFS" || drlmBkpProt == "\"NETFS\"" {
			if drlmBkpProg == "TAR" || drlmBkpProg == "\"TAR\"" || drlmBkpProg == "" {
				clientConfig = "OUTPUT=PXE\n"
				clientConfig += "OUTPUT_PREFIX=PXE\n"
				clientConfig += "OUTPUT_PREFIX_PXE=" + c.Name + "/" + configName + "/PXE\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "NETFS_PREFIX=backup\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
			} else if drlmBkpProg == "RSYNC" || drlmBkpProg == "\"RSYNC\"" {
				clientConfig = "OUTPUT=PXE\n"
				clientConfig += "OUTPUT_PREFIX=PXE\n"
				clientConfig += "OUTPUT_PREFIX_PXE=" + c.Name + "/" + configName + "/PXE\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "BACKUP_PROG=rsync\n"
				clientConfig += "NETFS_PREFIX=\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			}
		}
		/////////////
		// DATA
		/////////////
	} else if drlmBkpType == "DATA" || drlmBkpType == "\"DATA\"" {
		if drlmBkpProt == "RSYNC" || drlmBkpProt == "\"RSYNC\"" || drlmBkpProt == "" {
			clientConfig = "export RSYNC_PASSWORD=$(cat /etc/rear/drlm.token)\n"
			clientConfig += "OUTPUT=ISO\n"
			clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
			clientConfig += "BACKUP=RSYNC\n"
			clientConfig += "RSYNC_PREFIX=\n"
			clientConfig += "BACKUP_URL=rsync://" + c.Name + "@" + serverIP + "::/" + c.Name + "_" + configName + "\n"
			clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			clientConfig += "BACKUP_ONLY_INCLUDE=yes\n"
			if drlmBkpSecProt == "yes" || drlmBkpSecProt == "\"yes\"" || drlmBkpSecProt == "" {
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( '-e stunnel /etc/rear/stunnel/drlm.conf' )\n"
				clientConfig += "RSYNC_PORT=874\n"
				clientConfig += "REQUIRED_PROGS+=( 'stunnel' )\n"
			}
		} else if drlmBkpProt == "NETFS" || drlmBkpProt == "\"NETFS\"" {
			if drlmBkpProg == "TAR" || drlmBkpProg == "\"TAR\"" || drlmBkpProg == "" {
				clientConfig = "OUTPUT=ISO\n"
				clientConfig += "OUTPUT_PREFIX=\n"
				clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "NETFS_PREFIX=backup\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
				clientConfig += "BACKUP_ONLY_INCLUDE=yes\n"
			} else if drlmBkpProg == "RSYNC" || drlmBkpProg == "\"RSYNC\"" {
				clientConfig = "OUTPUT=ISO\n"
				clientConfig += "OUTPUT_PREFIX=\n"
				clientConfig += "ISO_PREFIX=" + c.Name + "-" + configName + "-DRLM-recover\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "BACKUP_PROG=rsync\n"
				clientConfig += "NETFS_PREFIX=\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
				clientConfig += "BACKUP_ONLY_INCLUDE=yes\n"
			}
		}
		clientConfig += "TARGET_FS_DATA=/var/tmp/drlm/restored\n"
		/////////////
		// RAWDISK
		/////////////
	} else if drlmBkpType == "RAWDISK" || drlmBkpType == "\"RAWDISK\"" {
		if drlmBkpProt == "RSYNC" || drlmBkpProt == "\"RSYNC\"" || drlmBkpProt == "" {
			clientConfig = "export RSYNC_PASSWORD=$(cat /etc/rear/drlm.token)\n"
			clientConfig += "OUTPUT=RAWDISK\n"
			clientConfig += "OUTPUT_PREFIX=RAWDISK\n"
			clientConfig += "RAWDISK_IMAGE_COMPRESSION_COMMAND=\n"
			clientConfig += "BACKUP=RSYNC\n"
			clientConfig += "RSYNC_PREFIX=\n"
			clientConfig += "BACKUP_URL=rsync://" + c.Name + "@" + serverIP + "::/" + c.Name + "_" + configName + "\n"
			clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			if drlmBkpSecProt == "yes" || drlmBkpSecProt == "\"yes\"" || drlmBkpSecProt == "" {
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( '-e stunnel /etc/rear/stunnel/drlm.conf' )\n"
				clientConfig += "RSYNC_PORT=874\n"
				clientConfig += "REQUIRED_PROGS+=( 'stunnel' )\n"
			}
		} else if drlmBkpProt == "NETFS" || drlmBkpProt == "\"NETFS\"" {
			if drlmBkpProg == "TAR" || drlmBkpProg == "\"TAR\"" || drlmBkpProg == "" {
				clientConfig = "OUTPUT=RAWDISK\n"
				clientConfig += "OUTPUT_PREFIX=RAWDISK\n"
				clientConfig += "RAWDISK_IMAGE_COMPRESSION_COMMAND=\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "NETFS_PREFIX=backup\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
			} else if drlmBkpProg == "RSYNC" || drlmBkpProg == "\"RSYNC\"" {
				clientConfig = "OUTPUT=RAWDISK\n"
				clientConfig += "RAWDISK_IMAGE_COMPRESSION_COMMAND=\n"
				clientConfig += "OUTPUT_PREFIX=\n"
				clientConfig += "BACKUP=NETFS\n"
				clientConfig += "BACKUP_PROG=rsync\n"
				clientConfig += "NETFS_PREFIX=\n"
				clientConfig += "BACKUP_URL=nfs://" + serverIP + configDRLM.StoreDir + "/" + c.Name + "/" + configName + "\n"
				clientConfig += "BACKUP_RSYNC_OPTIONS+=( --devices --acls --xattrs )\n"
			}
		}
	}
	SSHRootPasswordValue := ""
	if found, tmpValue := getConfigFileVar("/etc/drlm/local.conf", "SSH_ROOT_PASSWORD"); found {
		SSHRootPasswordValue = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/site.conf", "SSH_ROOT_PASSWORD"); found {
		SSHRootPasswordValue = tmpValue
	}
	if SSHRootPasswordValue != "" {
		clientConfig += "SSH_ROOT_PASSWORD=" + SSHRootPasswordValue + "\n"
	} else {
		clientConfig += "SSH_ROOT_PASSWORD='drlm'\n"
	}

	return clientConfig
}

// Generate and send client backup configuration
func (c *Client) sendConfig(w http.ResponseWriter, configName string, vipClient string) {

	if configName == "/" || configName == "" {
		configName = "default"
	}

	// find the configuration in the client configurations
	for i := range c.Configs {
		if c.Configs[i].Name == configName {

			// If vipClient !="" we need to change the client_name@ to the vipClient@ in the BACKUP_URL
			if vipClient != "" {
				c.Configs[i].Content = strings.Replace(c.Configs[i].Content, c.Name+"@", vipClient+"@", -1)
			}

			w.Write([]byte(c.Configs[i].Content))
			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(http.StatusOK)
			return
		}
	}
	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusNotFound)
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
		logger.Println(err.Error())
		return "", err
	}
	defer f.Close()

	// Splits on newlines by default.
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(strings.Split(scanner.Text(), "#")[0])
		if line != "" {
			//Have a new line from config file and get the var name
			varName := strings.TrimSpace(strings.Split(line, "=")[0])

			//Ignore old configurations (< DRLM 2.4.0)
			//if varName != "OUTPUT" && varName != "OUTPUT_PREFIX" && varName != "OUTPUT_PREFIX_PXE" && varName != "OUTPUT_URL" && varName != "BACKUP" && varName != "NETFS_PREFIX" && varName != "BACKUP_URL" {
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
			//}
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
		logger.Println("Error getting clients")
		w.WriteHeader(http.StatusInternalServerError)
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

	if len(r.Context().Value(ctxKey{}).(CtxValues).matches) > 1 {
		receivedConfig = getField(r, 1)
	}

	client := new(Client)
	client.GetByName(receivedClientName)

	vipClientName := ""
	// check if is VIP client
	if client.VIP != "" {
		receivedClientIP, _, _ := net.SplitHostPort(r.RemoteAddr)
		vipIPs, _ := client.getClientVipIPs()
		if contains(vipIPs, receivedClientIP) {
			vipClientName, _ = client.getClientNameByIP(receivedClientIP)
		}
	}

	client.sendConfig(w, receivedConfig, vipClientName)
}

// Get JSON of selected client
func apiGetClient(w http.ResponseWriter, r *http.Request) {
	receivedClientID := getField(r, 0)

	client := new(Client)
	err := client.GetByID(receivedClientID)
	if err == nil {
		fmt.Fprintln(w, generateJSONResponse(client))
	} else {
		logger.Println("Client", receivedClientID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}
}

// Get all Configurations of the selected client name
func apiGetClientConfigs(w http.ResponseWriter, r *http.Request) {
	receivedClientID := getField(r, 0)
	client := new(Client)
	err := client.GetByID(receivedClientID)
	if err == nil {
		fmt.Fprintln(w, generateJSONResponse(client.Configs))
	} else {
		logger.Println("Client", receivedClientID, "not found")
		w.WriteHeader(http.StatusNotFound)
	}
}

// Get selected Configuration of the selected client ID
func apiGetClientConfig(w http.ResponseWriter, r *http.Request) {
	receivedClientID := getField(r, 0)
	receivedClientConfig := getField(r, 1)

	client := new(Client)
	err := client.GetByID(receivedClientID)
	if err != nil {
		logger.Println("Client", receivedClientID, "not found")
		w.WriteHeader(http.StatusNotFound)
		return
	}

	for i := range client.Configs {
		if client.Configs[i].Name == receivedClientConfig {
			configFileName := client.Configs[i].File
			configContent := client.Configs[i].Content
			fmt.Fprintln(w, generateJSONResponse(ClientConfig{Name: receivedClientConfig, File: configFileName, Content: configContent}))
			return
		}
	}

	logger.Println("Config", receivedClientConfig, "not found in client", receivedClientID)
	w.WriteHeader(http.StatusNotFound)
}

// Get all backups of the selected client ID
func apiGetClientBackups(w http.ResponseWriter, r *http.Request) {
	receivedClientID := getField(r, 0)

	client := new(Client)
	err := client.GetByID(receivedClientID)
	if err != nil {
		logger.Println("Client", receivedClientID, "not found")
		w.WriteHeader(http.StatusNotFound)
		return
	}

	response := ""
	clientBackups, err := client.GetBackups()

	if err == nil {
		response = generateJSONResponse(clientBackups)
	} else {
		response = generateJSONResponse("")
		logger.Println("Error getting bakcups")
		w.WriteHeader(http.StatusInternalServerError)
	}

	fmt.Fprintln(w, response)
}
