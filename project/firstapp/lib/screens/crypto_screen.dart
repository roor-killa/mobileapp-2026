import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // L'outil graphique
import '../services/api_service.dart';

// Constantes couleurs
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color zinc700 = Color(0xFF27272A); // Ajout du gris pour les bordures
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
  
  // Période du graphique
  int _selectedPeriod = 100; // 12=1H, 100=1D, 500=1W, 1000=All
  
  double _prixActuel = 0.0;
  double _soldeEuros = 0.0;
  double _soldeBkn = 0.0;
  
  // Variables pour le graphique
  List<dynamic> _history = [];
  double _high = 0.0;
  double _low = 0.0;

  @override
  void initState() {
    super.initState();
    _chargerMarche();
  }

  Future<void> _chargerMarche() async {
    setState(() => _isLoading = true);
    
    // On appelle l'API avec la limite choisie par l'utilisateur (ex: 1W)
    final data = await _apiService.getMarketData(limit: _selectedPeriod);
    
    if (!mounted) return;

    if (data['success'] == true) {
      // 1. On récupère l'historique
      final historyList = data['price_history'] as List<dynamic>? ?? [];
      
      // 2. Calcul du Plus Haut et Plus Bas pour l'affichage
      double tempHigh = 0;
      double tempLow = 999999;
      
      for (var item in historyList) {
        double price = double.parse(item['prix'].toString()); 
        if (price > tempHigh) tempHigh = price;
        if (price < tempLow) tempLow = price;
      }

      setState(() {
        _prixActuel = double.parse(data['current_price'].toString());
        _soldeEuros = double.parse(data['user_solde_eur'].toString());
        _soldeBkn = double.parse(data['user_solde_bkn'].toString());
        _history = historyList;
        _high = tempHigh == 0 ? _prixActuel : tempHigh;
        _low = tempLow == 999999 ? _prixActuel : tempLow;
        _isLoading = false;
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('solde', _soldeEuros);
    } else {
       setState(() => _isLoading = false);
    }
  }

  void _changePeriod(int newPeriod) {
    if (_selectedPeriod == newPeriod) return;
    setState(() => _selectedPeriod = newPeriod);
    _chargerMarche();
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
    // Calcul du coût ou du gain estimé dans l'input
    double totalCost = (double.tryParse(_quantiteController.text) ?? 0) * _prixActuel;
    
    // Calcul de la valeur en euros du solde BKN actuel
    double valeurSoldeEnEuros = _soldeBkn * _prixActuel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- EN-TÊTE : TITRE ET SOLDE BKN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: zinc700)),
                    child: const Icon(Icons.trending_up, color: emerald500),
                  ),
                  const SizedBox(width: 15),
                  const Text('Marché', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              // NOUVEAU : Affichage du Solde BKN en haut à droite
              if (!_isLoading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${_soldeBkn.toStringAsFixed(2)} BKN', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('≈ ${valeurSoldeEnEuros.toStringAsFixed(2)} €', style: const TextStyle(color: emerald500, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )
            ],
          ),
          const SizedBox(height: 25),

          // BLOC GRAPHIQUE
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(32), border: Border.all(color: zinc700)),
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
                        _isLoading 
                            ? const SizedBox(height: 33, width: 100, child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator(color: emerald500, strokeWidth: 2)))
                            : Text('${_prixActuel.toStringAsFixed(4)} €', style: const TextStyle(color: emerald500, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("PLUS HAUT", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            Text("${_high.toStringAsFixed(4)} €", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("PLUS BAS", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            Text("${_low.toStringAsFixed(4)} €", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                
                // Boutons de période
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Center(child: _buildPeriodButton('1H', 12))),
                      Expanded(child: Center(child: _buildPeriodButton('1J', 100))),
                      Expanded(child: Center(child: _buildPeriodButton('1S', 500))),
                      Expanded(child: Center(child: _buildPeriodButton('TOUT', 1000))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Le Graphique Fl_chart
                SizedBox(
                  height: 180, 
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: emerald500))
                      : _buildChart(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // BLOC DE TRADE
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(32), border: Border.all(color: zinc700)),
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
                          onTap: () => setState(() { _tradeType = 'BUY'; _quantiteController.clear(); }),
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
                          onTap: () => setState(() { _tradeType = 'SELL'; _quantiteController.clear(); }),
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

                // Input Quantité
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('QUANTITÉ BKN', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Text('Dispo: ${_tradeType == 'BUY' ? '${_soldeEuros.toStringAsFixed(2)} €' : '${_soldeBkn.toStringAsFixed(2)} BKN'}', style: const TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantiteController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  onChanged: (val) => setState(() {}),
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

  // --- WIDGETS UTILES ---

  Widget _buildPeriodButton(String label, int value) {
    bool isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => _changePeriod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? emerald500 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : textGray,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_history.length < 2) return const Center(child: Text("Pas assez de données", style: TextStyle(color: textGray)));

    List<FlSpot> spots = [];
    for (int i = 0; i < _history.length; i++) {
      double price = double.parse(_history[i]['prix'].toString());
      spots.add(FlSpot(i.toDouble(), price));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false), 
        titlesData: const FlTitlesData(show: false), 
        borderData: FlBorderData(show: false), 
        minX: 0, maxX: (_history.length - 1).toDouble(),
        minY: _low - 0.05, maxY: _high + 0.05, 
        lineBarsData: [
          LineChartBarData(
            spots: spots, 
            isCurved: true, 
            color: emerald500, 
            barWidth: 3, 
            isStrokeCapRound: true, 
            dotData: const FlDotData(show: false), 
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
    );
  }
}