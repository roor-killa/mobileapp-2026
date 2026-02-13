import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Méthode générique de dépôt
  Future<void> _processDeposit(int minAmount, String method) async {
    final amount = int.tryParse(_amountController.text);
    
    if (amount == null) {
      _showError("Veuillez saisir un montant");
      return;
    }
    
    if (amount < minAmount) {
      _showError("Le minimum pour $method est de $minAmount BKN");
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulation délai réseau
    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await ApiService.deposit(amount);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rechargement de $amount BKN réussi ($method) !"), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        _showError("Erreur lors du dépôt");
      }
    } catch (e) {
      _showError("Erreur réseau");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Recharger"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2962FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2962FF),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance), text: "Virement"),
            Tab(icon: Icon(Icons.credit_card), text: "Carte"),
            Tab(icon: Icon(Icons.qr_code), text: "Tiers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: VIREMENT
          _buildDepositTab(
            title: "Virement Immédiat",
            desc: "Créditez votre compte instantanément via Open Banking.",
            minAmount: 5,
            icon: Icons.account_balance,
            color: Colors.purple,
            buttonText: "INITIER LE VIREMENT",
          ),

          // TAB 2: CARTE BANCAIRE
          _buildDepositTab(
            title: "Carte Bancaire",
            desc: "Utilisez votre carte VISA ou Mastercard.",
            minAmount: 10,
            icon: Icons.credit_card,
            color: const Color(0xFF2962FF),
            buttonText: "PAYER PAR CARTE",
            showCardMockup: true,
          ),

          // TAB 3: TIERS (QR Code)
          _buildThirdPartyTab(),
        ],
      ),
    );
  }

  Widget _buildDepositTab({
    required String title,
    required String desc,
    required int minAmount,
    required IconData icon,
    required Color color,
    required String buttonText,
    bool showCardMockup = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          const Text("Montant à créditer", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            decoration: InputDecoration(
              prefixText: "+ ",
              suffixText: "BKN",
              hintText: "0",
              helperText: "Minimum : $minAmount BKN",
              filled: true,
              fillColor: color.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),

          if (showCardMockup) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white),
                  const SizedBox(width: 15),
                  const Text("**** 4242", style: TextStyle(color: Colors.white, fontSize: 18)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text("Changer"))
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: _isLoading ? null : () => _processDeposit(minAmount, title),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_2, size: 150, color: Colors.black),
          const SizedBox(height: 20),
          const Text("Faites scanner ce code", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Demandez à un ami de scanner ce code pour vous envoyer de l'argent instantanément.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Partager mon lien"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien copié dans le presse-papier !")));
              },
            ),
          )
        ],
      ),
    );
  }
}
