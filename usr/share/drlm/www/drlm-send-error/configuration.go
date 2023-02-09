package main

import (
	"bufio"
	"os"
	"strings"
)

type Configuration struct {
	DRLMSendErrorURL string
}

var configDRLMSendError Configuration

func loadDRLMSendErrorConfiguration() {

	if found, tmpValue := getConfigFileVar("/usr/share/drlm/conf/default.conf", "DRLM_SEND_ERROR_URL"); found {
		configDRLMSendError.DRLMSendErrorURL = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/local.conf", "DRLM_SEND_ERROR_URL"); found {
		configDRLMSendError.DRLMSendErrorURL = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/site.conf", "DRLM_SEND_ERROR_URL"); found {
		configDRLMSendError.DRLMSendErrorURL = tmpValue
	}

	if configDRLMSendError.DRLMSendErrorURL == "" {
		logger.Println("DRLM_SEND_ERROR_URL not found in DRLM config. Can not send XML/JSON error.")
		return
	}
}

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

	if err := scanner.Err(); err != nil {
		// Handle the error
	}

	return found, foundVAR
}
