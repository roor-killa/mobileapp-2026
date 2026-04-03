package com.example.bankapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.ViewGroup;
import android.widget.*;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import com.example.bankapp.R;
import com.example.bankapp.api.*;
import com.example.bankapp.models.User;
import retrofit2.*;

public class ProfileActivity extends AppCompatActivity {

    private EditText etName, etEmail;
    private Button btnUpdate, btnLogout, btnChangePass;
    private TextView tvIban;
    private int userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        // 1. Initialisation
        etName = findViewById(R.id.etProfileName);
        etEmail = findViewById(R.id.etProfileEmail);
        btnUpdate = findViewById(R.id.btnUpdateProfile);
        btnLogout = findViewById(R.id.btnLogout);
        btnChangePass = findViewById(R.id.btnChangePassword);
        tvIban = findViewById(R.id.tvIban); // IBAN

        // 2. Récupération des données
        userId = getIntent().getIntExtra("USER_ID", -1);
        String currentName = getIntent().getStringExtra("USER_NAME");
        String currentEmail = getIntent().getStringExtra("USER_EMAIL");
        String iban = getIntent().getStringExtra("USER_IBAN"); // IBAN

        etName.setText(currentName);
        etEmail.setText(currentEmail);
        tvIban.setText(iban != null ? iban : "Non disponible"); // IBAN

        // 3. Action Enregistrer
        btnUpdate.setOnClickListener(v -> {
            String newName = etName.getText().toString().trim();
            String newEmail = etEmail.getText().toString().trim();
            if (!newName.isEmpty() && !newEmail.isEmpty()) {
                updateUserProfile(newName, newEmail);
            }
        });

        // 4. Action Déconnexion
        btnLogout.setOnClickListener(v -> {
            Intent intent = new Intent(ProfileActivity.this, LoginActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });

        // 5. Action Changer Mot de Passe
        btnChangePass.setOnClickListener(v -> showPasswordDialog());
    }

    private void showPasswordDialog() {
        final EditText etNewPass = new EditText(this);
        etNewPass.setHint("Nouveau mot de passe");
        etNewPass.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);

        FrameLayout container = new FrameLayout(this);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.leftMargin = 50;
        params.rightMargin = 50;
        etNewPass.setLayoutParams(params);
        container.addView(etNewPass);

        new AlertDialog.Builder(this)
                .setTitle("Sécurité")
                .setMessage("Entrez votre nouveau mot de passe :")
                .setView(container)
                .setPositiveButton("Modifier", (dialog, which) -> {
                    String pass = etNewPass.getText().toString().trim();
                    if (!pass.isEmpty()) sendPasswordUpdate(pass);
                })
                .setNegativeButton("Annuler", null)
                .show();
    }

    private void updateUserProfile(String name, String email) {
        ApiService api = ApiClient.getClient().create(ApiService.class);
        User user = new User();
        user.setId(userId);
        user.setName(name);
        user.setEmail(email);

        api.updateAccount(user).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(ProfileActivity.this, "✅ Profil mis à jour !", Toast.LENGTH_SHORT).show();
                    finish();
                }
            }
            @Override
            public void onFailure(Call<User> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Erreur réseau", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void sendPasswordUpdate(String newPassword) {
        ApiService api = ApiClient.getClient().create(ApiService.class);
        User user = new User();
        user.setId(userId);
        user.setPassword(newPassword);

        api.updateAccount(user).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(ProfileActivity.this, "🔑 Mot de passe modifié !", Toast.LENGTH_SHORT).show();
                }
            }
            @Override
            public void onFailure(Call<User> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Erreur réseau", Toast.LENGTH_SHORT).show();
            }
        });
    }
}