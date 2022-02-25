package main

import (
	"bufio"
	"os"
	"strings"
)

type Configuration struct {
	RedirectURL       string
	CurrenturlURLBase string
}

var configDRLMProxy Configuration

func loadDRLMProxyConfiguration() {

	if found, tmpValue := getConfigFileVar("/usr/share/drlm/conf/default.conf", "DRLM_PROXY_URL"); found {
		configDRLMProxy.RedirectURL = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/local.conf", "DRLM_PROXY_URL"); found {
		configDRLMProxy.RedirectURL = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/site.conf", "DRLM_PROXY_URL"); found {
		configDRLMProxy.RedirectURL = tmpValue
	}

	if configDRLMProxy.RedirectURL == "" {
		logger.Fatal("DRLM_PROXY_URL not found in DRLM config. Impossible to redirect requests")
		return
	} else {
		logger.Println(configDRLMProxy.RedirectURL)
	}

	if found, tmpValue := getConfigFileVar("/usr/share/drlm/conf/default.conf", "URL_REAR_BASE"); found {
		configDRLMProxy.CurrenturlURLBase = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/local.conf", "URL_REAR_BASE"); found {
		configDRLMProxy.CurrenturlURLBase = tmpValue
	}
	if found, tmpValue := getConfigFileVar("/etc/drlm/site.conf", "URL_REAR_BASE"); found {
		configDRLMProxy.CurrenturlURLBase = tmpValue
	}

	if configDRLMProxy.CurrenturlURLBase == "" {
		logger.Println("WARNING! URL_REAR_BASE not found in DRLM config. ReaR packages URL may be incorrect")
	} else {
		logger.Println(configDRLMProxy.CurrenturlURLBase)
	}
}

func printDRLMProxyConfiguration() {
	logger.Println("================================")
	logger.Println("=== DRLM PROXY CONFIGURATION ===")
	logger.Println("================================")
	logger.Println("DRLM_PROXY_URL=" + configDRLMProxy.RedirectURL)
	logger.Println("URL_REAR_BASE=" + configDRLMProxy.CurrenturlURLBase)
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
