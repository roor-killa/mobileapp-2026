package com.example.bankapp.adapters;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import com.example.bankapp.R;
import com.example.bankapp.models.Transaction;
import java.util.List;

public class TransactionAdapter extends ArrayAdapter<Transaction> {

    public TransactionAdapter(Context context, List<Transaction> transactions) {
        super(context, 0, transactions);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = LayoutInflater.from(getContext())
                    .inflate(R.layout.item_transaction, parent, false);
        }

        Transaction tx = getItem(position);

        TextView tvIcon   = convertView.findViewById(R.id.tvTxIcon);
        TextView tvLabel  = convertView.findViewById(R.id.tvTxLabel);
        TextView tvDate   = convertView.findViewById(R.id.tvTxDate);
        TextView tvAmount = convertView.findViewById(R.id.tvTxAmount);

        boolean isCredit = tx.getAmount() >= 0;

        // Cercle coloré
        GradientDrawable circle = new GradientDrawable();
        circle.setShape(GradientDrawable.OVAL);
        if (isCredit) {
            circle.setColor(0xFFE8F8EF);
            tvIcon.setText("+");
            tvIcon.setTextColor(0xFF1A7A4A);
        } else {
            circle.setColor(0xFFFEF0EF);
            tvIcon.setText("-");
            tvIcon.setTextColor(0xFFC0392B);
        }
        tvIcon.setBackground(circle);

        // Textes
        tvLabel.setText(tx.getLabel() != null ? tx.getLabel() : tx.getType());
        tvDate.setText(tx.getDate());

        // Montant
        String amountStr = String.format("%+.2f €", tx.getAmount());
        tvAmount.setText(amountStr);
        tvAmount.setTextColor(isCredit ? 0xFF1A7A4A : 0xFFC0392B);

        return convertView;
    }
}