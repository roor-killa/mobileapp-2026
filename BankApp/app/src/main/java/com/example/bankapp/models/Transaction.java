package com.example.bankapp.models;

public class Transaction {
    private String type;
    private double amount;
    private String date;
    private String label;

    public String getType() { return type; }
    public double getAmount() { return amount; }
    public String getDate() { return date; }
    public String getLabel() { return label; }
}