package models

type User struct {
	Username string `json:"user_name"`
	Password string `json:"user_password"`
}

type UserResponse struct {
	Version string `json:"version"`
	Result  []User `json:"result"`
}
