package com.example.bankapp.models;

public class LoginRequest {
    private String email;
    private String password;

    // Constructeur
    public LoginRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }

    // Getters (Indispensables pour que Retrofit accède aux données)
    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    // Setters (Optionnels mais pratiques)
    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}