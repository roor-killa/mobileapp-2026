import 'package:flutter/material.dart';

class VirementMain extends StatefulWidget {
  const VirementMain({super.key});
  @override
  State<VirementMain> createState() => _VirementMainState();
}

class _VirementMainState extends State<VirementMain> {
  void _montrerFormulaire(String titre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF001A35),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "Bénéficiaire (IBAN ou Nom)",
              ),
            ),
            const TextField(
              decoration: InputDecoration(labelText: "Montant (€)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Virement envoyé avec succès !"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "CONFIRMER",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "VIREMENTS & ENVOIS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildTile("Ajouter un bénéficiaire", Icons.person_add, Colors.blue),
        _buildTile("Virement Classique", Icons.send, Colors.green),
        _buildTile("Wero / Western Union", Icons.public, Colors.orange),
        _buildTile("Faire un Don", Icons.favorite, Colors.red),
        const Divider(height: 40),
        const Text("HISTORIQUE", style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTile("Historique des virements", Icons.history, Colors.grey),
      ],
    );
  }

  Widget _buildTile(String t, IconData i, Color c) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: Icon(i, color: c),
        title: Text(t),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _montrerFormulaire(t),
      ),
    );
  }
}
