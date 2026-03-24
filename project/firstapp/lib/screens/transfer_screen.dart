import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/transfer_response.dart';

// --- COULEURS DU THEME ---
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color emerald700 = Color(0xFF047857);
const Color textGray = Color(0xFF71717A);

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final ApiService _apiService = ApiService();
  
  double _soldeActuel = 0.0;
  double _soldeBkn = 0.0; // Pour les statistiques rapides
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerSoldeInitial();
  }

  Future<void> _chargerSoldeInitial() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soldeActuel = prefs.getDouble('solde') ?? 0.00;
    });

    // 1. Solde en Euros
    final vraiSolde = await _apiService.getLiveBalance();
    if (vraiSolde != null && vraiSolde != _soldeActuel) {
      setState(() => _soldeActuel = vraiSolde);
      await prefs.setDouble('solde', vraiSolde); 
    }

    // 2. Solde en BKN (Pour la carte Stats)
    final marketData = await _apiService.getMarketData();
    if (marketData['success'] == true) {
      setState(() {
        _soldeBkn = double.parse(marketData['user_solde_bkn'].toString());
      });
    }

    setState(() => _isLoading = false);
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: emerald500));
  }

  // =========================================================
  // MODAL : RECHARGEMENT (Glisse depuis le bas)
  // =========================================================
  void _afficherBottomSheetRechargement() {
    final TextEditingController topupController = TextEditingController();
    bool isToppingUp = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 30),
              decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 30),
                  const Text('Recharger mon compte', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  
                  const Text('MONTANT (EUR)', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: topupController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "0.00", hintStyle: TextStyle(color: Colors.grey.shade800),
                      filled: true, fillColor: bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  isToppingUp
                      ? const Center(child: CircularProgressIndicator(color: emerald500))
                      : ElevatedButton.icon(
                          onPressed: () async {
                            final montant = double.tryParse(topupController.text.trim());
                            if (montant == null || montant < 5.0) {
                              _afficherErreur("Minimum 5 € requis."); return;
                            }
                            setStateSheet(() => isToppingUp = true);
                            final result = await _apiService.topUp(montant);

                            if (result['success'] == true) {
                              Navigator.pop(context);
                              _chargerSoldeInitial(); // Rafraîchit l'écran
                              _afficherSucces(result['message']);
                            } else {
                              setStateSheet(() => isToppingUp = false);
                              _afficherErreur(result['message'] ?? 'Erreur');
                            }
                          },
                          icon: const Icon(Icons.credit_card, color: Colors.black),
                          label: const Text('CONFIRMER LE PAIEMENT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(backgroundColor: emerald500, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // =========================================================
  // MODAL : TRANSFERT (Glisse depuis le bas)
  // =========================================================
  void _afficherBottomSheetTransfert() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController montantController = TextEditingController();
    bool isTransferring = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 30),
              decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 30),
                  const Text('Envoyer de l\'argent', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  
                  const Text('DESTINATAIRE', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Email de l'utilisateur", hintStyle: TextStyle(color: Colors.grey.shade800),
                      filled: true, fillColor: bgDark,
                      prefixIcon: const Icon(Icons.alternate_email, color: textGray),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('MONTANT (EUR)', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: montantController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "0.00", hintStyle: TextStyle(color: Colors.grey.shade800),
                      filled: true, fillColor: bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  isTransferring
                      ? const Center(child: CircularProgressIndicator(color: emerald500))
                      : ElevatedButton.icon(
                          onPressed: () async {
                            final montant = double.tryParse(montantController.text.trim());
                            if (emailController.text.isEmpty || montant == null || montant <= 0) {
                              _afficherErreur("Données invalides."); return;
                            }
                            setStateSheet(() => isTransferring = true);
                            final response = await _apiService.transfererMontant(emailController.text.trim(), montant);

                            if (response.success) {
                              Navigator.pop(context);
                              _chargerSoldeInitial();
                              _afficherSucces(response.message);
                            } else {
                              setStateSheet(() => isTransferring = false);
                              _afficherErreur(response.message);
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.black),
                          label: const Text('CONFIRMER L\'ENVOI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: emerald500));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // 1. LA CARTE DE SOLDE (Gradient Emerald)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [emerald500, emerald700], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: emerald500.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SOLDE PRINCIPAL', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add, color: Colors.black, size: 20),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Text('${_soldeActuel.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _afficherBottomSheetRechargement,
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text('Recharger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _afficherBottomSheetTransfert,
                        icon: const Icon(Icons.send, color: Colors.black, size: 18),
                        label: const Text('Envoyer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.3), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // 2. ACTIONS RAPIDES (Grille)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade900)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: emerald500.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.qr_code_scanner, color: emerald500)),
                      const SizedBox(height: 15),
                      const Text('QR CODE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade900)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: emerald500.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_add, color: emerald500)),
                      const SizedBox(height: 15),
                      const Text('AJOUT AGENT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // 3. STATISTIQUES RAPIDES
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade900)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STATISTIQUES RAPIDES', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_soldeBkn.toStringAsFixed(2)} BKN', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Portefeuille Crypto', style: TextStyle(color: textGray, fontSize: 12)),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+12.5%', style: TextStyle(color: emerald500, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Performance', style: TextStyle(color: textGray, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}