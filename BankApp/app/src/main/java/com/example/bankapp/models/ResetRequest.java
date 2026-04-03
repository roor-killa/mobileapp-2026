package com.example.bankapp.models;
public class ResetRequest {
    private String email;
    public ResetRequest(String email) { this.email = email; }
    public String getEmail() { return email; }
}
