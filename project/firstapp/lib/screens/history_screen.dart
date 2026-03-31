import 'package:flutter/material.dart';
import '../services/api_service.dart';

// --- COULEURS DU THEME ---
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color zinc700 = Color(0xFF27272A);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  // Variables pour les filtres
  String _selectedAccount = 'all'; 
  String _selectedType = 'Tout'; 

  // Données
  List<dynamic> _pockets = [];
  List<dynamic> _allTransactions = []; 
  List<dynamic> _filteredTransactions = []; 

  // Liste des filtres rapides
  final List<String> _filterTypes = ['Tout', 'Envoyés', 'Reçus', 'Crypto (BKN)'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pocketsData = await _apiService.getPockets();
      if (pocketsData['success'] == true && mounted) {
        setState(() {
          _pockets = pocketsData['pockets'] ?? [];
        });
      }

      final dynamic result = await _apiService.getTransactions();
      
      if (!mounted) return;
      
      if (result is List) {
        _allTransactions = List.from(result);
      } else if (result is Map && result['success'] == true) {
        _allTransactions = List.from(result['transactions']);
      }

      _applyFilters();
      
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        final type = tx['type'].toString().toLowerCase();
        
        bool matchType = false;
        if (_selectedType == 'Tout') {
          matchType = true;
        } else if (_selectedType == 'Envoyés') {
          matchType = (type == 'envoi' || type == 'transfert_sortant');
        } else if (_selectedType == 'Reçus') {
          matchType = (type == 'reception' || type == 'rechargement' || type == 'transfert_entrant');
        } else if (_selectedType == 'Crypto (BKN)') {
          matchType = (type == 'achat_bkn' || type == 'vente_bkn');
        }

        bool matchAccount = false;
        if (_selectedAccount == 'all') {
          matchAccount = true;
        } else if (_selectedAccount == 'main') {
          matchAccount = (tx['pocket_id'] == null);
        } else {
          matchAccount = (tx['pocket_id'].toString() == _selectedAccount);
        }

        return matchType && matchAccount;
      }).toList();

      // --- NOUVEAUTÉ : ON TRIE PAR DATE (Du plus récent au plus ancien) ---
      _filteredTransactions.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['created_at'] ?? '');
          final dateB = DateTime.parse(b['created_at'] ?? '');
          return dateB.compareTo(dateA); // CompareTo inversé = ordre décroissant
        } catch (e) {
          return 0;
        }
      });

      _isLoading = false;
    });
  }

  // --- NOUVEAUTÉ : PETIT HELPER POUR OBTENIR "MARS 2026" ---
  String _getMoisAnnee(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      const mois = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return "${mois[date.month - 1]} ${date.year}";
    } catch (e) {
      return "Inconnu";
    }
  }

  String _formaterDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- EN-TÊTE : TITRE ---
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: zinc700)),
                child: const Icon(Icons.history, color: emerald500),
              ),
              const SizedBox(width: 15),
              const Text('Historique', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // --- MENU DÉROULANT DES COMPTES ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: zinc700),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAccount,
                dropdownColor: cardDark,
                icon: const Icon(Icons.keyboard_arrow_down, color: textGray),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Toutes les transactions')),
                  const DropdownMenuItem(value: 'main', child: Text('Solde Principal')),
                  ..._pockets.map((pocket) {
                    return DropdownMenuItem(
                      value: pocket['id'].toString(), 
                      child: Text('${pocket['nom']}')
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _selectedAccount = val;
                    _applyFilters(); 
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- FILTRES RAPIDES ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: _filterTypes.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () {
                  _selectedType = type;
                  _applyFilters(); 
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? emerald500 : cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? emerald500 : zinc700),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 25),

        // --- LISTE DES TRANSACTIONS GROUPÉES PAR MOIS ---
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: emerald500))
            : _filteredTransactions.isEmpty
              ? const Center(child: Text("Aucune transaction trouvée.", style: TextStyle(color: textGray, fontStyle: FontStyle.italic)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: _filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = _filteredTransactions[index];
                    final dateCompleteStr = tx['created_at'] ?? '';
                    final moisCourant = _getMoisAnnee(dateCompleteStr);

                    // LOGIQUE D'AFFICHAGE DU TITRE DE MOIS
                    bool afficherTitreMois = false;
                    if (index == 0) {
                      afficherTitreMois = true; // Toujours afficher pour le 1er élément
                    } else {
                      final moisPrecedent = _getMoisAnnee(_filteredTransactions[index - 1]['created_at'] ?? '');
                      if (moisCourant != moisPrecedent) {
                        afficherTitreMois = true; // Afficher si le mois a changé
                      }
                    }

                    final type = tx['type'].toString().toLowerCase();
                    final isSortie = type == 'envoi' || type == 'achat_bkn' || type == 'transfert_sortant';
                    final montant = double.parse(tx['montant'].toString());
                    
                    final couleurMontant = isSortie ? Colors.white : emerald500;
                    final signe = isSortie ? "-" : "+";
                    
                    IconData icone;
                    Color couleurIcone = textGray;

                    if (type == 'rechargement') {
                      icone = Icons.account_balance_wallet;
                      couleurIcone = emerald500;
                    } else if (type == 'achat_bkn' || type == 'vente_bkn') {
                      icone = Icons.currency_bitcoin;
                      couleurIcone = Colors.orange;
                    } else if (type.contains('transfert')) {
                      icone = Icons.swap_horiz;
                      couleurIcone = Colors.purpleAccent;
                    } else {
                      icone = isSortie ? Icons.arrow_upward : Icons.arrow_downward;
                      couleurIcone = isSortie ? textGray : emerald500;
                    }

                    // On retourne une "Column" pour pouvoir empiler le titre du mois (facultatif) et la carte
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de section du mois (ex: MARS 2026)
                        if (afficherTitreMois)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 15, left: 5),
                            child: Text(
                              moisCourant.toUpperCase(),
                              style: const TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                          
                        // La carte de la transaction
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: zinc700),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: couleurIcone.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16)
                                ),
                                child: Icon(icone, color: couleurIcone, size: 24),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx['description'] ?? 'Transaction', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(_formaterDate(dateCompleteStr), style: const TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  ],
                                ),
                              ),
                              Text(
                                '$signe ${montant.toStringAsFixed(2)} €',
                                style: TextStyle(color: couleurMontant, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        )
      ],
    );
  }
}