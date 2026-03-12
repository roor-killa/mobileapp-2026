import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- LA NOUVELLE LIBRAIRIE MAGIQUE
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
  
  // La liste des points pour notre graphique (Coordonnées X et Y)
  List<FlSpot> _spots = [];
  // --- NOUVELLE SECTION : GRAPHIQUE ET INFOS FAÇON REVOLUT ---
  Widget _buildAnalyseSection() {
    // 1. On calcule le prix le plus bas et le plus haut pour les labels
    double minPrix = _spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxPrix = _spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITRE DE LA SECTION
        const Text(
          'Analyse et Historique du BKN (7 Jours)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 20),
        
        // LE GRAPHIQUE LISSÉ
        SizedBox(
          height: 150, // Hauteur du graphique
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false), // On cache la grille moche
              titlesData: const FlTitlesData(show: false), // On cache les textes sur les côtés (style épuré)
              borderData: FlBorderData(show: false), // On cache la bordure carrée
              minX: 0,
              maxX: (_spots.length - 1).toDouble(),
              minY: minPrix - 0.05, // On laisse un peu de marge en bas
              maxY: maxPrix + 0.05, // On laisse un peu de marge en haut
              lineBarsData: [
                LineChartBarData(
                  spots: _spots,
                  isCurved: true, // COURBE LISSÉE !
                  color: Colors.amber, // Couleur de la ligne
                  barWidth: 3, // Épaisseur de la ligne
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false), // On cache les gros points à chaque croisement
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.amber.withOpacity(0.15), // Joli dégradé transparent en dessous !
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 15),
        
        // PETITE LEGENDE POUR EXPLIQUER (Nouveau)
        _buildLegendTile(Icons.trending_up, 'Plus Haut', '${maxPrix.toStringAsFixed(4)} €', Colors.green),
        const SizedBox(height: 10),
        _buildLegendTile(Icons.trending_down, 'Plus Bas', '${minPrix.toStringAsFixed(4)} €', Colors.red),
      ],
    );
  }

  // Fonction utilitaire pour créer les petites lignes de légende
  Widget _buildLegendTile(IconData icone, String titre, String valeur, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icone, color: couleur, size: 20),
              const SizedBox(width: 10),
              Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Text(valeur, style: TextStyle(color: couleur, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // --- SECTION TRADE : BALANCES ET BOUTONS ACHAT/VENTE (Déplacé) ---
  Widget _buildTradeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // VOS PORTEFEUILLES (Maintenant groupés dans un conteneur gris)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              const Text('Vos Portefeuilles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPortefeuilleCard('Euros', '${_soldeEuros.toStringAsFixed(2)} €', Colors.blue),
                  _buildPortefeuilleCard('Jetons BKN', '${_soldeBkn.toStringAsFixed(2)} BKN', Colors.amber.shade700),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),

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
                    onPressed: () => _trader(true),
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text('ACHETER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trader(false),
                    icon: const Icon(Icons.sell, color: Colors.white),
                    label: const Text('VENDRE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            )
      ],
    );
  }
  

  @override
  void initState() {
    super.initState();
    _chargerMarche();
  }

  Future<void> _chargerMarche() async {
    final data = await _apiService.getMarketData();
    if (data['success'] == true) {
      
      // On prépare les données pour le graphique !
      List<FlSpot> nouveauxSpots = [];
      if (data['price_history'] != null) {
        final historique = data['price_history'] as List;
        for (int i = 0; i < historique.length; i++) {
          double prix = double.parse(historique[i]['prix'].toString());
          nouveauxSpots.add(FlSpot(i.toDouble(), prix)); // X = le temps (0, 1, 2...), Y = le prix
        }
      }

      setState(() {
        _prixActuel = double.parse(data['current_price'].toString());
        _soldeEuros = double.parse(data['user_solde_eur'].toString());
        _soldeBkn = double.parse(data['user_solde_bkn'].toString());
        _spots = nouveauxSpots; // On sauvegarde les points
        _isLoading = false;
      });
      
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

    final resultat = isAchat 
        ? await _apiService.buyBkn(quantite) 
        : await _apiService.sellBkn(quantite);

    setState(() => _isTrading = false);

    if (resultat['success'] == true) {
      _quantiteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultat['message']), backgroundColor: Colors.green),
      );
      _chargerMarche(); // Rafraîchit les prix ET redessine le graphique !
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
          // 1. L'AFFICHEUR DU PRIX BKN (Reste en haut)
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

          // 2. VÉRIFICATION : ASSEZ DE DONNÉES ? (Nouveau placement)
          // On n'affiche le graphique que si on a assez de points
          if (_spots.length < 2) 
            const SizedBox(
              height: 100,
              child: Center(child: Text("Pas encore assez de données", style: TextStyle(color: Colors.grey))),
            )
          else
            // 3. LA NOUVELLE SECTION ANALYSE (Graphique + Infos)
            _buildAnalyseSection(), // <-- J'APPELLE LA NOUVELLE FONCTION ICI

          const SizedBox(height: 30),

          // 4. ZONE DE TRADE (Conteneur avec les balances)
          _buildTradeSection(), // <-- J'AI DÉPLACÉ LA LOGIQUE DE TRADE DANS CETTE FONCTION

          const SizedBox(height: 40), // Espace final pour ne pas coller en bas
        ],
      ),
    );
  }
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
