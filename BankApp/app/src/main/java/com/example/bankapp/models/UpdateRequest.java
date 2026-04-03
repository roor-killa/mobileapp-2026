package com.example.bankapp.models;

public class UpdateRequest {
    private int id;
    private String name;
    private String email;

    public UpdateRequest(int id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }
}