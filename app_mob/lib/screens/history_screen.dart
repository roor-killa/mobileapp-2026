import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Cache pour les noms des utilisateurs pour éviter de requêter la DB en boucle
  final Map<String, String> _userNamesCache = {};
  String? _myId;

  @override
  void initState() {
    super.initState();
    _myId = _supabase.auth.currentUser?.id;
    _preloadUserNames();
  }

  // Charge tous les noms d'utilisateurs une bonne fois pour toutes
  Future<void> _preloadUserNames() async {
    final response = await _supabase.from('profiles').select('id, full_name');
    if (mounted) {
      setState(() {
        for (var user in response) {
          _userNamesCache[user['id']] = user['full_name'];
        }
      });
    }
  }

  String _getUserName(String userId) {
    if (userId == _myId) return "Moi";
    return _userNamesCache[userId] ?? "Utilisateur inconnu";
  }

  Stream<List<Map<String, dynamic>>> _getTransactionsStream() {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        backgroundColor: Colors.indigo.shade100,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Aucune transaction trouvée"),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final bool isReceived = tx['receiver_id'] == _myId;
              final amount = tx['amount'];
              final date = DateTime.parse(tx['created_at']).toLocal();
              final dateStr = DateFormat('dd MMM yyyy à HH:mm').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReceived ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isReceived ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    isReceived
                        ? "Reçu de ${_getUserName(tx['sender_id'])}"
                        : "Envoyé à ${_getUserName(tx['receiver_id'])}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dateStr),
                  trailing: Text(
                    "${isReceived ? '+' : '-'} ${amount.toStringAsFixed(2)} €",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isReceived ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
