package com.example.bankapp.activities;

import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.example.bankapp.R;
import com.example.bankapp.api.*;
import com.example.bankapp.models.TransferRequest;
import com.example.bankapp.models.User;
import retrofit2.*;

public class TransferActivity extends AppCompatActivity {

    private EditText etRecipient, etAmount;
    private Button btnConfirm;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_transfer);

        etRecipient = findViewById(R.id.etRecipient);
        etAmount = findViewById(R.id.etAmount);
        btnConfirm = findViewById(R.id.btnConfirmTransfer);

        btnConfirm.setOnClickListener(v -> {
            // RÉCUPÉRATION DE L'ID REÇU DE LA HOME
            int finalSenderId = getIntent().getIntExtra("USER_ID", -1);

            String destEmail = etRecipient.getText().toString().trim();
            String amountStr = etAmount.getText().toString().trim();

            // Vérification de sécurité
            if (finalSenderId == -1) {
                Toast.makeText(this, "Erreur d'ID utilisateur", Toast.LENGTH_SHORT).show();
                return;
            }

            if (destEmail.isEmpty() || amountStr.isEmpty()) {
                Toast.makeText(this, "Champs vides", Toast.LENGTH_SHORT).show();
                return;
            }

            double amountValue = Double.parseDouble(amountStr);

            // ENVOI DE LA REQUÊTE
            TransferRequest request = new TransferRequest(finalSenderId, destEmail, amountValue);
            ApiService api = ApiClient.getClient().create(ApiService.class);

            api.makeTransfer(request).enqueue(new Callback<User>() {
                @Override
                public void onResponse(Call<User> call, Response<User> response) {
                    if (response.isSuccessful()) {
                        Toast.makeText(TransferActivity.this, "Virement réussi !", Toast.LENGTH_SHORT).show();
                        finish(); // Retour à la Home
                    } else {
                        Toast.makeText(TransferActivity.this, "Échec : Solde insuffisant ou destinataire inconnu", Toast.LENGTH_LONG).show();
                    }
                }

                @Override
                public void onFailure(Call<User> call, Throwable t) {
                    Toast.makeText(TransferActivity.this, "Erreur réseau", Toast.LENGTH_SHORT).show();
                }
            });
        });
    }
}