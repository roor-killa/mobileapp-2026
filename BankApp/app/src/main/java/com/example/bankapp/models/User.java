package com.example.bankapp.models;
import java.util.List;

public class User {
    private int id;
    private String name;
    private String email;
    private String password;
    private double balance;
    private List<Transaction> history;
    private String iban;

    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public double getBalance() { return balance; }
    public List<Transaction> getHistory() { return history; }
    public String getIban() { return iban; }

    // SETTERS (Ceux qui manquent et causent l'erreur rouge)
    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
}