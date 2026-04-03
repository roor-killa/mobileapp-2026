package com.example.bankapp.models;

public class TransferRequest {
    private int fromId;
    private String toEmail;
    private double amount;

    public TransferRequest(int fromId, String toEmail, double amount) {
        this.fromId = fromId;
        this.toEmail = toEmail;
        this.amount = amount;
    }

    public int getFromId() { return fromId; }
    public String getToEmail() { return toEmail; }
    public double getAmount() { return amount; }
}