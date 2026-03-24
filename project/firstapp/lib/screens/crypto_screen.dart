import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

// Constantes couleurs
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

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
  String _tradeType = 'BUY'; // 'BUY' ou 'SELL'
  
  double _prixActuel = 0.0;
  double _soldeEuros = 0.0;
  double _soldeBkn = 0.0;
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _chargerMarche();
  }

  Future<void> _chargerMarche() async {
    final data = await _apiService.getMarketData();
    if (data['success'] == true) {
      List<FlSpot> nouveauxSpots = [];
      if (data['price_history'] != null) {
        final historique = data['price_history'] as List;
        for (int i = 0; i < historique.length; i++) {
          double prix = double.parse(historique[i]['prix'].toString());
          nouveauxSpots.add(FlSpot(i.toDouble(), prix));
        }
      }

      setState(() {
        _prixActuel = double.parse(data['current_price'].toString());
        _soldeEuros = double.parse(data['user_solde_eur'].toString());
        _soldeBkn = double.parse(data['user_solde_bkn'].toString());
        _spots = nouveauxSpots;
        _isLoading = false;
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('solde', _soldeEuros);
    }
  }

  Future<void> _trader() async {
    final quantite = double.tryParse(_quantiteController.text.trim());
    if (quantite == null || quantite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantité invalide'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isTrading = true);
    final isAchat = _tradeType == 'BUY';
    final resultat = isAchat ? await _apiService.buyBkn(quantite) : await _apiService.sellBkn(quantite);
    setState(() => _isTrading = false);

    if (resultat['success'] == true) {
      _quantiteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultat['message']), backgroundColor: emerald500));
      _chargerMarche(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultat['message'] ?? 'Erreur'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: emerald500));

    double minPrix = _spots.isNotEmpty ? _spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) : 0;
    double maxPrix = _spots.isNotEmpty ? _spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0;
    double totalCost = (double.tryParse(_quantiteController.text) ?? 0) * _prixActuel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade900)),
                child: const Icon(Icons.trending_up, color: emerald500),
              ),
              const SizedBox(width: 15),
              const Text('Marché BKN', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),

          // Graphique Card
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.grey.shade900)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRIX ACTUEL', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text('${_prixActuel.toStringAsFixed(4)} €', style: const TextStyle(color: emerald500, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('PLUS HAUT', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text('${maxPrix.toStringAsFixed(4)} €', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text('PLUS BAS', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text('${minPrix.toStringAsFixed(4)} €', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                
                // Le Graphique
                if (_spots.length >= 2)
                  SizedBox(
                    height: 180, 
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false), 
                        titlesData: const FlTitlesData(show: false), 
                        borderData: FlBorderData(show: false), 
                        minX: 0, maxX: (_spots.length - 1).toDouble(),
                        minY: minPrix - 0.02, maxY: maxPrix + 0.02, 
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots, isCurved: true, color: emerald500, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false), 
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [emerald500.withOpacity(0.3), emerald500.withOpacity(0.0)],
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // Zone de Trade
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.grey.shade900)),
            child: Column(
              children: [
                // Toggle Acheter / Vendre
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tradeType = 'BUY'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tradeType == 'BUY' ? emerald500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text('ACHETER', style: TextStyle(color: _tradeType == 'BUY' ? Colors.black : textGray, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tradeType = 'SELL'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tradeType == 'SELL' ? emerald500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text('VENDRE', style: TextStyle(color: _tradeType == 'SELL' ? Colors.black : textGray, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),

                // Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('QUANTITÉ BKN', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Text('Dispo: ${_tradeType == 'BUY' ? '$_soldeEuros €' : '$_soldeBkn BKN'}', style: const TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantiteController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  onChanged: (val) => setState(() {}), // Pour mettre à jour le Total
                  decoration: InputDecoration(
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.grey.shade800),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Total: ${totalCost.toStringAsFixed(2)} €', style: const TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),

                const SizedBox(height: 25),

                // Bouton Valider
                _isTrading 
                  ? const CircularProgressIndicator(color: emerald500)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _trader,
                        icon: Icon(_tradeType == 'BUY' ? Icons.shopping_cart : Icons.sell, color: Colors.black),
                        label: Text(_tradeType == 'BUY' ? "CONFIRMER L'ACHAT" : "CONFIRMER LA VENTE", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald500,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}