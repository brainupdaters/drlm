// www/drlm-send-error/drlm-send-error.go

package main

import (
	"bytes"
	"encoding/xml"
	"net/http"
	"os"
)

type Error struct {
	XMLName       xml.Name `xml:"drlm"`
	Version       string   `xml:"version"`
	Type          string   `xml:"type"`
	Server        string   `xml:"server"`
	Client        string   `xml:"client"`
	Configuration string   `xml:"configuration"`
	OS            string   `xml:"os"`
	Rear          string   `xml:"rear"`
	Workflow      string   `xml:"workflow"`
	Message       string   `xml:"message"`
}

func main() {
	// Load DRLM SEND ERROR configuration vars
	loadDRLMSendErrorConfiguration()

	if configDRLMSendError.DRLMSendErrorURL != "" {

		var body []byte

		//If only one argument is provided means that is an XML string
		//else we recieve 9 parameters and have to be Marshalled
		if len(os.Args) == 2 {
			body = []byte(os.Args[1])
		} else {
			error := &Error{}
			error.Version = os.Args[1]
			error.Type = os.Args[2]
			error.Server = os.Args[3]
			error.Client = os.Args[4]
			error.Configuration = os.Args[5]
			error.OS = os.Args[6]
			error.Rear = os.Args[7]
			error.Workflow = os.Args[8]
			error.Message = os.Args[9]
			body, _ = xml.Marshal(error)
		}
		client := &http.Client{}

		//Log the sended error in /var/log/drlm/drlm-send-error-log
		logger.Println("Sending error " + string(body) + " to " + configDRLMSendError.DRLMSendErrorURL)

		req, err := http.NewRequest("POST", configDRLMSendError.DRLMSendErrorURL, bytes.NewBuffer([]byte(body)))
		if err != nil {
			logger.Println(err)
		}

		req.Header.Add("Content-Type", "application/xml; charset=utf-8")

		//Send request to configDRLMSendError.DRLMSendErrorURL
		resp, err := client.Do(req)
		if err != nil {
			logger.Println(err)
		}
		//Log the response
		logger.Println(resp)
	}
}
