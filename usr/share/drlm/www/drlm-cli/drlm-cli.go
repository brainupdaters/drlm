package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"

	"../drlm-api/models"
)

//type ClientResultList models.ClientResultList

func main() {

	// permit non secure transport
	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}

	/////////////////////////////////////////////
	// GET SESSION TROKEN (SIGNIN)
	/////////////////////////////////////////////
	sessionToken := ""

	if sessionToken == "" {
		// create request with user an password
		values := map[string]string{"username": "admindrlm", "password": "admindrlm", "version": "1.0.0", "platform": "drlm-cli"}

		json_data, err := json.Marshal(values)
		if err != nil {
			log.Fatal(err)
		}
		resp, err := http.Post("https://192.168.123.132/signin", "application/json", bytes.NewBuffer(json_data))
		if err != nil {
			log.Fatal(err)
		}

		// get session token value
		for _, cookie := range resp.Cookies() {
			sessionToken = cookie.Value
		}

	}

	fmt.Println("Session Token:", sessionToken)
	/////////////////////////////////////////////
	/////////////////////////////////////////////

	/////////////////////////////////////////////
	// FETCH ALL CLIENTS
	/////////////////////////////////////////////
	b, err := HTTPwithCookies("https://192.168.123.132/api/clients", "GET", sessionToken)
	if err != nil {
		fmt.Println(err.Error())
	}

	var resposta models.ClientResponse

	err = json.Unmarshal(b, &resposta)
	if err != nil {
		panic(err)
	}

	for _, cli := range resposta.Result {
		fmt.Println("========================== ")
		fmt.Println("   Nom Client:", cli.Name)
		fmt.Println("========================== ")

		for _, conf := range cli.Configs {
			fmt.Println("-Nom Config:", conf.Name)
			fmt.Println("-Fitxer:", conf.File)
			fmt.Println(" ")

			//fmt.Println("Configuracio:\n", conf.Content)
		}
		fmt.Println(" ")
	}
	/////////////////////////////////////////////
	/////////////////////////////////////////////

	/////////////////////////////////////////////
	// FETCH ONE CLIENT
	/////////////////////////////////////////////
	clientID := "100"
	b, err = HTTPwithCookies("https://192.168.123.132/api/clients/"+clientID+"/configs", "GET", sessionToken)

	var configsResp models.ClientConfigResponse

	err = json.Unmarshal(b, &configsResp)
	if err != nil {
		panic(err)
	}

	for _, cfg := range configsResp.Result {
		fmt.Println(cfg.Name)
	}
	// fmt.Println(string(b))
	/////////////////////////////////////////////
	/////////////////////////////////////////////

	/////////////////////////////////////////////
	// LOGOUT
	/////////////////////////////////////////////
	b, err = HTTPwithCookies("https://192.168.123.132/logout", "POST", sessionToken)
	/////////////////////////////////////////////
	/////////////////////////////////////////////
}

func HTTPwithCookies(url, method, sessionToken string) (b []byte, err error) {
	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		return
	}

	req.AddCookie(&http.Cookie{Name: "session_token", Value: sessionToken})

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		err = errors.New(url +
			"\nresp.StatusCode: " + strconv.Itoa(resp.StatusCode))
		return
	}

	return ioutil.ReadAll(resp.Body)
}
