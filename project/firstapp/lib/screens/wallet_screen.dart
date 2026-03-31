import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// --- COULEURS DU THEME ---
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color emerald700 = Color(0xFF047857);
const Color textGray = Color(0xFF71717A);

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _apiService = ApiService();
  
  double _soldeActuel = 0.0;
  double _soldeBkn = 0.0;
  List<dynamic> _pockets = []; 
  bool _isLoading = true;
  String _userEmail = "utilisateur@mail.com"; 

  @override
  void initState() {
    super.initState();
    _chargerSoldeInitial();
  }

  Future<void> _chargerSoldeInitial() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _soldeActuel = prefs.getDouble('solde') ?? 0.00;
        _userEmail = prefs.getString('email') ?? "boss@mail.com"; 
      });
    }

    // 1. Solde en Euros
    final vraiSolde = await _apiService.getLiveBalance();
    if (vraiSolde != null && vraiSolde != _soldeActuel) {
      if (mounted) setState(() => _soldeActuel = vraiSolde);
      await prefs.setDouble('solde', vraiSolde); 
    }

    // 2. Solde en BKN
    final marketData = await _apiService.getMarketData();
    if (marketData['success'] == true && mounted) {
      setState(() {
        _soldeBkn = double.parse(marketData['user_solde_bkn'].toString());
      });
    }

    // 3. Charger les Pockets
    final pocketsData = await _apiService.getPockets();
    if (pocketsData['success'] == true && mounted) {
      setState(() {
        _pockets = pocketsData['pockets'] ?? [];
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: emerald500));
  }

  // =========================================================
  // MODAL : RECHARGEMENT
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
                              _chargerSoldeInitial();
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
  // MODAL : TRANSFERT
  // =========================================================
  void _afficherBottomSheetTransfert({String? emailPreRempli}) {
    final TextEditingController emailController = TextEditingController(text: emailPreRempli ?? "");
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
  // MODAL : PAYER
  // =========================================================
  // =========================================================
  // MODAL : PAYER
  // =========================================================
  void _afficherBottomSheetPaiement({String? pocketPreRempli}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30, top: 30),
          decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 30),
              Text('Paiement : ${pocketPreRempli ?? "Solde Principal"}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Cette fonctionnalité nécessitera une mise à jour de l\'API pour déduire l\'argent d\'un pocket ou du solde principal lors d\'un achat physique.', style: TextStyle(color: textGray, fontSize: 12)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: emerald500, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('COMPRIS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    );
  }

  // =========================================================
  // MODAL : CRÉER UN SOUS-COMPTE
  // =========================================================
  void _afficherBottomSheetCreationPocket() {
    final TextEditingController nomController = TextEditingController();
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30, top: 30),
              decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 30),
                  const Text('Nouveau sous-compte', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  
                  const Text('NOM DE LA CATÉGORIE', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nomController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Ex: Courses, Vacances...", hintStyle: TextStyle(color: Colors.grey.shade800),
                      filled: true, fillColor: bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  isCreating
                      ? const Center(child: CircularProgressIndicator(color: emerald500))
                      : ElevatedButton(
                          onPressed: () async {
                            if (nomController.text.trim().isEmpty) return;
                            setStateSheet(() => isCreating = true);
                            
                            final result = await _apiService.createPocket(nomController.text.trim());
                            if (result['success'] == true) {
                              Navigator.pop(context); // Ferme la popup
                              _chargerSoldeInitial(); // Recharge les pockets
                              _afficherSucces("Sous-compte créé !");
                            } else {
                              setStateSheet(() => isCreating = false);
                              _afficherErreur(result['message'] ?? 'Erreur');
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: emerald500, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: const Text('CRÉER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                ],
              ),
            );
          }
        );
      }
    );
  }
// =========================================================
  // MODAL : TRANSFERT VERS/DEPUIS UN POCKET
  // =========================================================
  void _afficherBottomSheetTransfertPocket(dynamic pocket) {
    final TextEditingController montantController = TextEditingController();
    bool isTransferring = false;
    String direction = 'to_pocket'; // Par défaut, on envoie vers le pocket

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30, top: 30),
              decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 30),
                  Text('Gérer : ${pocket['nom']}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  
                  const Text('DIRECTION DU TRANSFERT', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  // Menu déroulant pour choisir le sens
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(16)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: direction,
                        dropdownColor: cardDark,
                        icon: const Icon(Icons.keyboard_arrow_down, color: textGray),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: 'to_pocket', child: Text('Depuis Solde Principal ➡️ Vers ce Pocket')),
                          DropdownMenuItem(value: 'to_main', child: Text('Depuis ce Pocket ➡️ Vers Solde Principal')),
                        ],
                        onChanged: (val) {
                          if (val != null) setStateSheet(() => direction = val);
                        },
                      ),
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
                            if (montant == null || montant <= 0) {
                              _afficherErreur("Montant invalide."); return;
                            }
                            
                            // SÉCURITÉ FRONTEND : On vérifie les soldes avant même de demander au serveur
                            if (direction == 'to_pocket' && montant > _soldeActuel) {
                              _afficherErreur("Fonds insuffisants sur le Solde Principal."); return;
                            }
                            if (direction == 'to_main' && montant > double.parse(pocket['solde'].toString())) {
                              _afficherErreur("Fonds insuffisants dans ce sous-compte."); return;
                            }

                            setStateSheet(() => isTransferring = true);
                            
                            // Appel à l'API qu'on a codée précédemment
                            final result = await _apiService.transferPocket(pocket['id'], montant, direction);

                            if (result['success'] == true) {
                              Navigator.pop(context);
                              _chargerSoldeInitial(); // Met à jour tous les affichages
                              _afficherSucces(result['message'] ?? 'Transfert réussi !');
                              _showPocketsModal(); // Réouvre la liste des pockets pour voir le changement !
                            } else {
                              setStateSheet(() => isTransferring = false);
                              _afficherErreur(result['message'] ?? 'Erreur');
                            }
                          },
                          icon: const Icon(Icons.check, color: Colors.black),
                          label: const Text('CONFIRMER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(backgroundColor: emerald500, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                ],
              ),
            );
          }
        );
      }
    );
  }
  // =========================================================
  // MODAL : GÉRER LES SOUS-COMPTES (Pockets)
  // =========================================================
  void _showPocketsModal() {
    int? expandedPocketId; // Permet de savoir quel pocket est déplié

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                border: Border(top: BorderSide(color: Color(0xFF27272A))),
              ),
              child: Column(
                children: [
                  // En-tête (inchangé)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sous-comptes', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: cardDark, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // Bouton Créer (inchangé)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gérer mes sous-comptes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            // Petit rappel du solde disponible pour l'utilisateur
                            Text('Solde principal dispo : ${_soldeActuel.toStringAsFixed(2)} €', style: const TextStyle(color: emerald500, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                             Navigator.pop(context); 
                             _afficherBottomSheetCreationPocket(); 
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: emerald500, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.black, size: 24),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LISTE DES POCKETS (Avec l'accordéon)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: _pockets.map((pocket) {
                        final isExpanded = expandedPocketId == pocket['id'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: GestureDetector(
                            onTap: () {
                              setStateSheet(() {
                                // Si on clique sur celui déjà ouvert, ça le ferme. Sinon, ça l'ouvre.
                                expandedPocketId = isExpanded ? null : pocket['id'];
                              });
                            },
                            child: Column(
                              children: [
                                _buildPocketCard(pocket['nom'].toString().toUpperCase(), double.parse(pocket['solde'].toString())),
                                
                                // LES DEUX BOUTONS QUI APPARAISSENT SI DÉPLIÉ
                                if (isExpanded) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _afficherBottomSheetTransfertPocket(pocket); // Nouvelle fonction !
                                          },
                                          icon: const Icon(Icons.swap_horiz, color: emerald500, size: 18),
                                          label: const Text('Transférer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cardDark,
                                            side: const BorderSide(color: Color(0xFF27272A)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _afficherBottomSheetPaiement(pocketPreRempli: pocket['nom']);
                                          },
                                          icon: const Icon(Icons.credit_card, color: Colors.black, size: 18),
                                          label: const Text('Payer', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: emerald500,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  // =========================================================
  // MODAL : RECEVOIR (Génère le QR Code de l'utilisateur)
  // =========================================================
  void _afficherCodeQR() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            const Text('Recevoir des fonds', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(
                data: _userEmail, // Les données cachées dans le QR Code
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(_userEmail, style: const TextStyle(color: emerald500, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Faites scanner ce code pour recevoir de l\'argent directement sur votre compte.', textAlign: TextAlign.center, style: TextStyle(color: textGray)),
            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }

  // =========================================================
  // MODAL : ENVOYER (Allume la caméra et scanne)
  // =========================================================
  void _afficherScannerQR() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7, // Prend 70% de l'écran
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text('Scanner un QR Code', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Placez le QR Code dans le cadre pour envoyer de l\'argent.', textAlign: TextAlign.center, style: TextStyle(color: textGray, fontSize: 12)),
            const SizedBox(height: 30),
            
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? emailScanne = barcode.rawValue;
                      if (emailScanne != null && emailScanne.contains('@')) {
                        Navigator.pop(context); 
                        _afficherBottomSheetTransfert(emailPreRempli: emailScanne);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildPocketCard(String title, double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 5),
          Text('${amount.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
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
          // 1. CARTE DE SOLDE PRINCIPAL
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [emerald500, emerald700], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: emerald500.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SOLDE PRINCIPAL', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 5),
                Text('${_soldeActuel.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900)),
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _afficherBottomSheetRechargement(), 
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text('Recharger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _afficherBottomSheetTransfert(), 
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

          // ACTIONS RAPIDES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAction(Icons.qr_code_scanner, 'ENVOYER', emerald500, _afficherScannerQR),
              _buildQuickAction(Icons.qr_code, 'RECEVOIR', textGray, _afficherCodeQR),
              _buildQuickAction(Icons.credit_card, 'PAYER', emerald500, _afficherBottomSheetPaiement),
            ],
          ),
          const SizedBox(height: 25),

          // STATISTIQUES ET SOUS-COMPTES
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
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
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Color(0xFF27272A)),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SOUS-COMPTES', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    GestureDetector(
                      onTap: _showPocketsModal,
                      child: const Row(
                        children: [
                          Text('Gérer', style: TextStyle(color: emerald500, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right, color: emerald500, size: 16)
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                if (_pockets.isEmpty)
                  const Text('Aucun sous-compte pour le moment.', style: TextStyle(color: textGray, fontSize: 14, fontStyle: FontStyle.italic)),
                
                ..._pockets.take(3).map((pocket) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pocket['nom'].toString().toLowerCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${double.parse(pocket['solde'].toString()).toStringAsFixed(2)} €', style: const TextStyle(color: emerald500, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade900),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), 
              child: Icon(icon, color: iconColor)
            ),
            const SizedBox(height: 15),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}