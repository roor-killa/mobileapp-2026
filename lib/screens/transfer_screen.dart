import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_screen.dart';

class TransferScreen extends StatefulWidget {
  final Map user;
  final String token;

  const TransferScreen({super.key, required this.user, required this.token});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> transactions = [];

  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _destinataireController =
      TextEditingController();

  double balance = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final data = await _apiService.getTransactions(widget.user['id']);
    final solde = await _apiService.getBalance(widget.user['id']);
    print("SOLDE : $solde");

    setState(() {
      transactions = data;
      balance = solde;
    });
  }

  Future<void> _transfer() async {
    final montant = double.tryParse(_montantController.text);
    final email = _destinataireController.text;

    if (montant == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplis tous les champs")),
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await _apiService.transfererMontant(
      montant,
      email,
      widget.user['id'],
    );

    setState(() => isLoading = false);

    if (res['success'] == true) {
      _montantController.clear();
      _destinataireController.clear();

      // ✅ mise à jour du solde depuis la réponse API
      if (res['new_balance'] != null) {
        setState(() {
          balance = double.parse(res['new_balance'].toString());
        });
      }

      await _chargerDonnees();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Erreur transfert")),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            "${balance.toStringAsFixed(2)} €",
            style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Solde disponible",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Historique",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...transactions.map((t) {
          final isSender = t['sender_email'] == widget.user['email'];
          return Card(
              child: ListTile(
                leading: Icon(
                  t['sender_email'] == widget.user['email']
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: t['sender_email'] == widget.user['email']
                      ? Colors.red
                      : Colors.green,
                ),

                title: Text(
                  "${isSender ? '-' : '+'}${t['amount']} €",
                  style: TextStyle(
                    color: isSender ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text("${t['sender_email']} → ${t['receiver_email']}"),
              ),
            );
          })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Transfert d'argent",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.user['email'],
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              if (widget.user['is_admin'] == true)
                const PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 10),
                      Text('Dashboard Admin'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Se déconnecter'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _card(),
            const SizedBox(height: 40),

            TextField(
              controller: _montantController,
              decoration: const InputDecoration(
                  labelText: "Montant", prefixIcon: Icon(Icons.euro)),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _destinataireController,
              decoration: const InputDecoration(
                  labelText: "Email destinataire",
                  prefixIcon: Icon(Icons.email)),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: isLoading ? null : _transfer,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Envoyer"),
            ),

            const SizedBox(height: 20),

            Expanded(child: SingleChildScrollView(child: _history()))
          ],
        ),
      ),
    );
  }
}