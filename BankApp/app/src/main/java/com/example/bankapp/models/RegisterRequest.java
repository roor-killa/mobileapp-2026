package com.example.bankapp.models;

public class RegisterRequest {
    private String name;
    private String email;
    private String password;

    public RegisterRequest(String name, String email, String password) {
        this.name = name;
        this.email = email;
        this.password = password;
    }

    // Getters obligatoires pour Retrofit
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
}