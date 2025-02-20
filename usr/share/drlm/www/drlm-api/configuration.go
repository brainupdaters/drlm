// configuration.go
package main

import (
	"bufio"
	"os"
	"strings"
)

type Configuration struct {
	VarDir       string
	StoreDir     string
	SqliteFile   string
	CliConfigDir string
	RearLogDir   string
	APIPasswd    string
	Certificate  string
	Key          string
}

var configDRLM Configuration

func getVarValue(configLine, varName string) (bool, string) {
	found := false
	foundVAR := ""
	tempoVAR := ""

	if strings.Contains(configLine, varName) {
		// Remove the text behind #
		tempoVAR = strings.TrimSpace(strings.Split(configLine, "#")[0])
		if tempoVAR != "" {
			// if the name behind the = is equal the varName
			if strings.TrimSpace(strings.Split(tempoVAR, "=")[0]) == varName {
				// Get the text behind =
				tempoVAR = strings.TrimSpace(strings.Split(tempoVAR, "=")[1])
				// remove "
				tempoVAR = strings.Replace(tempoVAR, "\"", "", -1)
				// if is not empty assignt to return
				found = true
				foundVAR = tempoVAR
			}
		}
	}
	return found, foundVAR
}

func getConfigFileVar(configFile, varName string) (bool, string) {

	found := false
	foundVAR := ""

	f, e := os.Open(configFile)
	if e != nil {
		return found, foundVAR
	}
	defer f.Close()

	// Splits on newlines by default.
	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		if searchFound, tempoVAR := getVarValue(scanner.Text(), varName); searchFound {
			found = true
			foundVAR = tempoVAR
		}
	}

	err := scanner.Err()
	check(err)

	return found, foundVAR
}

func loadDRLMConfiguration() {

	// Create slice of configFiles
	configFiles := []string{
		"/usr/share/drlm/conf/default.conf",
		"/etc/drlm/local.conf",
		"/etc/drlm/site.conf",
	}

	// For each configFile
	for _, configFile := range configFiles {
		if found, tmpValue := getConfigFileVar(configFile, "VAR_DIR"); found {
			configDRLM.VarDir = tmpValue
		}
		if found, tmpValue := getConfigFileVar(configFile, "STORDIR"); found {
			configDRLM.StoreDir = tmpValue
		}
		if found, tmpValue := getConfigFileVar(configFile, "DB_PATH"); found {
			configDRLM.SqliteFile = tmpValue
		}
		if found, tmpValue := getConfigFileVar(configFile, "CLI_CONF_DIR"); found {
			configDRLM.CliConfigDir = tmpValue
		}
		if found, tmpValue := getConfigFileVar(configFile, "REAR_LOG_DIR"); found {
			configDRLM.RearLogDir = tmpValue
		}
		if found, tmpValue := getConfigFileVar(configFile, "API_PASSWD"); found {
			configDRLM.APIPasswd = tmpValue
		}
	}

	configDRLM.VarDir = strings.Replace(configDRLM.VarDir, "$DRLM_DIR_PREFIX", "", -1)
	configDRLM.StoreDir = strings.Replace(configDRLM.StoreDir, "$VAR_DIR", configDRLM.VarDir, -1)
	configDRLM.SqliteFile = strings.Replace(configDRLM.SqliteFile, "$VAR_DIR", configDRLM.VarDir, -1)

	// Set Certificate and Key path
	configDRLM.Certificate = "/etc/drlm/cert/drlm.crt"
	configDRLM.Key = "/etc/drlm/cert/drlm.key"
}

func printDRLMConfiguration() {
	logger.Println("==============================")
	logger.Println("=== DRLM API CONFIGURATION ===")
	logger.Println("==============================")
	logger.Println("VAR_DIR=" + configDRLM.VarDir)
	logger.Println("STORDIR=" + configDRLM.StoreDir)
	logger.Println("DB_PATH=" + configDRLM.SqliteFile)
	logger.Println("CLI_CONF_DIR=" + configDRLM.CliConfigDir)
	logger.Println("REAR_LOG_DIR=" + configDRLM.RearLogDir)
	logger.Println("DRLM_CERT=" + configDRLM.Certificate)
	logger.Println("DRLM_KEY=" + configDRLM.Key)
}

func updateDefaultAPIUser() {
	db := GetConnection()
	// update
	stmt, err := db.Prepare("update users set user_password=? where user_name='admindrlm'")
	check(err)

	_, err = stmt.Exec(GetMD5Hash(configDRLM.APIPasswd))
	check(err)
}
