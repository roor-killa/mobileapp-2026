import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'history_screen.dart'; // N'oublie pas d'importer le nouvel écran

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _amountController = TextEditingController();

  Map<String, dynamic>? _myProfile;
  List<Map<String, dynamic>> _otherUsers = [];
  Map<String, dynamic>? _selectedReceiver;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final myId = _supabase.auth.currentUser!.id;
      final myProfileData = await _supabase.from('profiles').select().eq('id', myId).single();
      final otherUsersData = await _supabase.from('profiles').select().neq('id', myId);

      if (mounted) {
        setState(() {
          _myProfile = myProfileData;
          _otherUsers = List<Map<String, dynamic>>.from(otherUsersData);
          if (_otherUsers.isNotEmpty) _selectedReceiver = _otherUsers.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur chargement")));
    }
  }

  Future<void> _makeTransfer() async {
    if (_myProfile == null || _selectedReceiver == null) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    if ((_myProfile!['balance'] as num) < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fonds insuffisants !")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabase.from('profiles').update({'balance': (_myProfile!['balance'] as num) - amount}).eq('id', _myProfile!['id']);
      final receiverFresh = await _supabase.from('profiles').select('balance').eq('id', _selectedReceiver!['id']).single();
      await _supabase.from('profiles').update({'balance': (receiverFresh['balance'] as num) + amount}).eq('id', _selectedReceiver!['id']);
      await _supabase.from('transactions').insert({
        'sender_id': _myProfile!['id'],
        'receiver_id': _selectedReceiver!['id'],
        'amount': amount,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transfert réussi !")));
      _amountController.clear();
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Compte"),
        backgroundColor: Colors.indigo.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Carte Solde
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Text(_myProfile?['full_name'] ?? "...", style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("${(_myProfile?['balance'] ?? 0).toStringAsFixed(2)} €",
                       style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Formulaire
            if (_otherUsers.isNotEmpty) ...[
              DropdownButtonFormField(
                value: _selectedReceiver,
                decoration: const InputDecoration(labelText: 'Destinataire', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                items: _otherUsers.map((u) => DropdownMenuItem(value: u, child: Text(u['full_name']))).toList(),
                onChanged: (val) => setState(() => _selectedReceiver = val),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.euro)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _makeTransfer,
                  icon: const Icon(Icons.send),
                  label: const Text("Envoyer maintenant"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ] else
              const Text("Attente d'autres utilisateurs..."),

            const Spacer(), // Pousse le bouton historique vers le bas

            // Bouton vers Historique
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text("Voir mon historique complet"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
