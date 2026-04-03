package com.example.bankapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import com.example.bankapp.R;
import com.example.bankapp.api.ApiClient;
import com.example.bankapp.api.ApiService;
import com.example.bankapp.models.LoginRequest;
import com.example.bankapp.models.ResetRequest;
import com.example.bankapp.models.User;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LoginActivity extends AppCompatActivity {

    private EditText etEmail, etPass;
    private Button btnLogin;
    private TextView tvSignUp, tvForgotPassword;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        etEmail = findViewById(R.id.etEmail);
        etPass = findViewById(R.id.etPassword);
        btnLogin = findViewById(R.id.btnLogin);
        tvSignUp = findViewById(R.id.tvSignUp);
        tvForgotPassword = findViewById(R.id.tvForgotPassword);

        tvSignUp.setOnClickListener(v ->
                startActivity(new Intent(this, SignUpActivity.class))
        );

        tvForgotPassword.setOnClickListener(v -> {
            EditText etResetEmail = new EditText(this);
            etResetEmail.setHint("Votre email");

            new AlertDialog.Builder(this)
                    .setTitle("Mot de passe oublié")
                    .setMessage("Entrez votre email :")
                    .setView(etResetEmail)
                    .setPositiveButton("Réinitialiser", (dialog, which) -> {
                        String email = etResetEmail.getText().toString().trim();
                        if (!email.isEmpty()) resetPassword(email);
                    })
                    .setNegativeButton("Annuler", null)
                    .show();
        });

        btnLogin.setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();
            String password = etPass.getText().toString().trim();

            if (!email.isEmpty() && !password.isEmpty()) {
                performLogin(email, password);
            } else {
                Toast.makeText(this, "Champs vides", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void performLogin(String email, String password) {
        ApiService apiService = ApiClient.getClient().create(ApiService.class);
        apiService.login(new LoginRequest(email, password)).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful() && response.body() != null) {
                    User user = response.body();
                    Intent i = new Intent(LoginActivity.this, HomeActivity.class);
                    i.putExtra("USER_ID", user.getId());
                    startActivity(i);
                    finish();
                } else {
                    Toast.makeText(LoginActivity.this, "Identifiants incorrects", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<User> call, Throwable t) {
                Toast.makeText(LoginActivity.this, "Erreur réseau", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void resetPassword(String email) {
        ApiService api = ApiClient.getClient().create(ApiService.class);
        api.resetPassword(new ResetRequest(email)).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(LoginActivity.this,
                            "Nouveau mot de passe : 1234", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(LoginActivity.this,
                            "Email introuvable", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<User> call, Throwable t) {
                Toast.makeText(LoginActivity.this, "Erreur réseau", Toast.LENGTH_SHORT).show();
            }
        });
    }
}