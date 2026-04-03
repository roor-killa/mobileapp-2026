package com.example.bankapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.example.bankapp.R;
import com.example.bankapp.adapters.TransactionAdapter;
import com.example.bankapp.api.*;
import com.example.bankapp.models.User;
import retrofit2.*;

public class HomeActivity extends AppCompatActivity {
    private TextView tvBalance;
    private ListView lvTransactions;
    private int userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        tvBalance = findViewById(R.id.tvBalanceAmount);
        lvTransactions = findViewById(R.id.lvTransactions);
        userId = getIntent().getIntExtra("USER_ID", -1);

        findViewById(R.id.btnTransfer).setOnClickListener(v -> {
            if (userId != -1) {
                Intent i = new Intent(HomeActivity.this, TransferActivity.class);
                i.putExtra("USER_ID", userId);
                startActivity(i);
            } else {
                Toast.makeText(this, "Session expirée", Toast.LENGTH_SHORT).show();
            }
        });

        findViewById(R.id.btnProfile).setOnClickListener(v -> {
            ApiService api = ApiClient.getClient().create(ApiService.class);
            api.getAccount(userId).enqueue(new Callback<User>() {
                @Override
                public void onResponse(Call<User> call, Response<User> response) {
                    if (response.isSuccessful() && response.body() != null) {
                        User user = response.body();
                        Intent i = new Intent(HomeActivity.this, ProfileActivity.class);
                        i.putExtra("USER_ID", user.getId());
                        i.putExtra("USER_NAME", user.getName());
                        i.putExtra("USER_EMAIL", user.getEmail());
                        i.putExtra("USER_IBAN", user.getIban());
                        startActivity(i);
                    }
                }
                @Override
                public void onFailure(Call<User> call, Throwable t) {}
            });
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (userId != -1) loadData();
    }

    private void loadData() {
        ApiService api = ApiClient.getClient().create(ApiService.class);
        api.getAccount(userId).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful() && response.body() != null) {
                    User user = response.body();
                    tvBalance.setText(String.format("%.2f €", user.getBalance()));
                    if (user.getHistory() != null) {
                        TransactionAdapter adapter = new TransactionAdapter(
                                HomeActivity.this, user.getHistory()
                        );
                        lvTransactions.setAdapter(adapter);
                        setListViewHeight(lvTransactions); // FIX SCROLL
                    }
                }
            }
            @Override
            public void onFailure(Call<User> call, Throwable t) {}
        });
    }

    private void setListViewHeight(ListView listView) {
        android.widget.ListAdapter adapter = listView.getAdapter();
        if (adapter == null) return;
        int totalHeight = 0;
        for (int i = 0; i < adapter.getCount(); i++) {
            View item = adapter.getView(i, null, listView);
            item.measure(
                    View.MeasureSpec.makeMeasureSpec(listView.getWidth(), View.MeasureSpec.AT_MOST),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            );
            totalHeight += item.getMeasuredHeight() + listView.getDividerHeight();
        }
        ViewGroup.LayoutParams params = listView.getLayoutParams();
        params.height = totalHeight + (listView.getDividerHeight() * (adapter.getCount() - 1));
        listView.setLayoutParams(params);
        listView.requestLayout();
    }
}