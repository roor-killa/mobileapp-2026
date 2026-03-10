import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _quantiteController = TextEditingController();
  
  bool _isLoading = true;
  bool _isTrading = false;
  
  double _prixActuel = 0.0;
  double _soldeEuros = 0.0;
  double _soldeBkn = 0.0;

  @override
  void initState() {
    super.initState();
    _chargerMarche();
  }

  Future<void> _chargerMarche() async {
    final data = await _apiService.getMarketData();
    if (data['success'] == true) {
      setState(() {
        _prixActuel = double.parse(data['current_price'].toString());
        _soldeEuros = double.parse(data['user_solde_eur'].toString());
        _soldeBkn = double.parse(data['user_solde_bkn'].toString());
        _isLoading = false;
      });
      // On met à jour le solde en euros dans le téléphone pour les autres onglets
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('solde', _soldeEuros);
    }
  }

  Future<void> _trader(bool isAchat) async {
    final quantite = double.tryParse(_quantiteController.text.trim());
    if (quantite == null || quantite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une quantité valide'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isTrading = true);

    // On appelle l'API selon le bouton cliqué (Achat ou Vente)
    final resultat = isAchat 
        ? await _apiService.buyBkn(quantite) 
        : await _apiService.sellBkn(quantite);

    setState(() => _isTrading = false);

    if (resultat['success'] == true) {
      _quantiteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultat['message']), backgroundColor: Colors.green),
      );
      _chargerMarche(); // On rafraîchit les prix et les soldes !
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultat['message'] ?? 'Erreur'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // L'AFFICHEUR DU PRIX BKN
          Card(
            color: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text('Cours du BKN', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    '${_prixActuel.toStringAsFixed(4)} €', 
                    style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // VOS PORTEFEUILLES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPortefeuilleCard('Euros', '${_soldeEuros.toStringAsFixed(2)} €', Colors.blue),
              _buildPortefeuilleCard('Jetons BKN', '${_soldeBkn.toStringAsFixed(2)} BKN', Colors.amber.shade700),
            ],
          ),
          const SizedBox(height: 40),

          // LA ZONE DE TRADE
          const Text('Combien de BKN voulez-vous trader ?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: _quantiteController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantité de BKN',
              prefixIcon: const Icon(Icons.currency_bitcoin),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          // LES BOUTONS ACHAT / VENTE
          _isTrading 
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _trader(true), // true = achat
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text('ACHETER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _trader(false), // false = vente
                      icon: const Icon(Icons.sell, color: Colors.white),
                      label: const Text('VENDRE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ),
                ],
              )
        ],
      ),
    );
  }

  Widget _buildPortefeuilleCard(String titre, String valeur, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(titre, style: TextStyle(color: couleur, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(valeur, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}