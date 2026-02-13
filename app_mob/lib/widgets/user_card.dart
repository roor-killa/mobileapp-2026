import 'package:flutter/material.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final bool isSender;

  const UserCard({
    super.key,
    required this.user,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSender ? Colors.indigo.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSender ? Colors.indigo : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 40, color: Colors.indigo),
          const SizedBox(height: 8),
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "${user.balance.toStringAsFixed(2)} €",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          if (isSender)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text("(Expéditeur)", style: TextStyle(fontSize: 10, color: Colors.indigo)),
            )
        ],
      ),
    );
  }
}
