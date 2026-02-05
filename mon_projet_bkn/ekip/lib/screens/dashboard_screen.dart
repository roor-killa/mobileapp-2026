import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  Future<void> _chargerHistorique() async {
    final data = await _apiService.getTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SOLUTION : On utilise DefaultTabController ici
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Historique des Transferts', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
              Tab(icon: Icon(Icons.data_object), text: 'Données JSON'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildVisualList(),
                  _buildJsonView(),
                ],
              ),
      ),
    );
  }

  // --- ONGLET 1 : LISTE VISUELLE ---
  Widget _buildVisualList() {
    if (_transactions.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final item = _transactions[index];
        return _buildTransactionCard(item);
      },
    );
  }

  Widget _buildTransactionCard(dynamic item) {
    final isUser1Sender = item['sender_id'] == 1;
    final amount = item['amount'];
    final date = item['date'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // Icône à gauche
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser1Sender ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUser1Sender ? Icons.arrow_outward : Icons.arrow_back,
            color: isUser1Sender ? Colors.blue : Colors.orange,
            size: 24,
          ),
        ),
        // Texte principal
        title: Text(
          isUser1Sender ? 'User 1 ➔ User 2' : 'User 2 ➔ User 1',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        // Date
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        // Montant à droite
        trailing: Text(
          '$amount €',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "Aucune transaction",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // --- ONGLET 2 : VUE JSON ---
  Widget _buildJsonView() {
    String prettyJson = const JsonEncoder.withIndent('  ').convert(_transactions);
    
    return Container(
      color: const Color(0xFF1E1E1E),
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText.rich(
          TextSpan(
            text: prettyJson,
            style: const TextStyle(
              fontFamily: 'Courier New',
              fontSize: 14,
              color: Color(0xFFD4D4D4),
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
