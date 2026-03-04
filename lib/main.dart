import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(const YannsBankApp());

class YannsBankApp extends StatelessWidget {
  const YannsBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Yann's BANK",
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0077BE),
      ),
      home: const BankHomePage(),
    );
  }
}

class BankHomePage extends StatefulWidget {
  const BankHomePage({super.key});

  @override
  State<BankHomePage> createState() => _BankHomePageState();
}

class _BankHomePageState extends State<BankHomePage> {
  // Variable pour le solde interactif du TP
  double solde = 4520.0;

  void ajouterArgent() {
    // Fonction setState pour mettre à jour l'écran
    setState(() {
      solde += 150.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: const Color(0xFF0077BE),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // Titre seul sans logo comme demandé
              title: const Text(
                "Yann's BANK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // TON IMAGE DE FOND RÉINTÉGRÉE
                  Image.asset(
                    'assets/images/erling-loken-andersen-7FiieOuoBTU-unsplash.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) =>
                        Container(color: const Color(0xFF0077BE)),
                  ),
                  Container(color: Colors.black.withOpacity(0.4)),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Solde Actuel',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '${solde.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // BOUTON DE VIREMENT (Exercice du TP)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: ajouterArgent,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Simuler un Virement (+150€)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // TES IMAGES RÉELLES (IMG_5462, IMG_5464)
                      _buildActionCard(
                        context,
                        'Cartes',
                        Icons.credit_card,
                        'assets/images/IMG_5462.jpeg',
                      ),
                      const SizedBox(width: 12),
                      _buildActionCard(
                        context,
                        'Épargne',
                        Icons.savings,
                        'assets/images/IMG_5464.jpeg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Dernières Opérations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildTransac(
                'Virement Salaire',
                '+ 2 500,00 €',
                Icons.work,
                Colors.green,
              ),
              _buildTransac(
                'Paiement Restaurant',
                '- 35,00 €',
                Icons.restaurant,
                Colors.orange,
              ),
              _buildTransac(
                'Achat en ligne (Web)',
                '- 89,99 €',
                Icons.shopping_cart,
                Colors.blue,
              ),
              _buildTransac(
                'Abonnement (Netflix/Spotify)',
                '- 12,99 €',
                Icons.subscriptions,
                Colors.red,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String imgPath,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imgPath),
            fit: BoxFit.cover,
            opacity: 0.3,
            onError: (e, s) => {},
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0077BE)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransac(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount.contains('+') ? Colors.green : Colors.black87,
          ),
        ),
      ),
    );
  }
}
