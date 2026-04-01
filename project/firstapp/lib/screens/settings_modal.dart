import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart'; // Décommente ça quand ton API sera prête

const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color zinc700 = Color(0xFF27272A);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  String _nom = "Boss";
  String _email = "boss@bkn.com";
  String _initiale = "B";

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom = prefs.getString('name') ?? "Leina MUSARAGANYI"; 
      _email = prefs.getString('email') ?? "mtleina@gmail.com";
      _initiale = _nom.isNotEmpty ? _nom[0].toUpperCase() : "B";
    });
  }

  Future<void> _seDeconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    // Navigator.of(context).pushAndRemoveUntil(...); // Redirection vers Login
  }

  // ---> NOUVEAU : La pop-up pour modifier le mot de passe <---
  // ---> CORRIGÉ : La pop-up pour modifier le mot de passe <---
  void _afficherPopupMotDePasse() {
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: cardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: zinc700)),
              title: const Text("Modifier le mot de passe", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordField(currentPwdController, "Mot de passe actuel"),
                  const SizedBox(height: 15),
                  _buildPasswordField(newPwdController, "Nouveau mot de passe"),
                  const SizedBox(height: 15),
                  _buildPasswordField(confirmPwdController, "Confirmer le nouveau"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // CORRECTION 1 : onPressed au lieu de onTap
                  child: const Text("Annuler", style: TextStyle(color: textGray, fontWeight: FontWeight.bold)),
                ),
                isLoading
                    ? const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CircularProgressIndicator(color: emerald500))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald500,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (newPwdController.text.isEmpty || currentPwdController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.redAccent));
                            return;
                          }
                          if (newPwdController.text != confirmPwdController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Les nouveaux mots de passe ne correspondent pas"), backgroundColor: Colors.redAccent));
                            return;
                          }

                          setStateDialog(() => isLoading = true);

                          // Simulation du chargement réseau (on force le type pour Dart)
                          await Future.delayed(const Duration(seconds: 2));
                          final Map<String, dynamic> resultat = {'success': true, 'message': 'Mot de passe modifié avec succès !'}; 

                          setStateDialog(() => isLoading = false);

                          // CORRECTION 3 : Vérification de sécurité après un await
                          if (!context.mounted) return;

                          // CORRECTION 2 : On utilise .toString() pour garantir que c'est du texte
                          if (resultat['success'] == true) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultat['message'].toString()), backgroundColor: emerald500));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultat['message'].toString()), backgroundColor: Colors.redAccent));
                          }
                        },
                        child: const Text("Valider", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
              ],
            );
          }
        );
      }
    );
  }

  // Widget utilitaire pour les champs de mot de passe
  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true, // Cache les caractères
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGray, fontSize: 13),
        filled: true,
        fillColor: bgDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, 
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paramètres', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: textGray), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 30),

          const Text('PROFIL', style: TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: zinc700)),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: emerald500, shape: BoxShape.circle),
                  child: Center(child: Text(_initiale, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nom, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_email, style: const TextStyle(color: textGray, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          const Text('SÉCURITÉ', style: TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          
          // ---> NOUVEAU : On relie le clic à la fonction de pop-up <---
          _buildListItem(Icons.settings_outlined, "Modifier le mot de passe", onTap: _afficherPopupMotDePasse),
          
          _buildListItem(Icons.person_outline, "Vérification d'identité"),
          
          const SizedBox(height: 20),
          const Divider(color: zinc700),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _seDeconnecter,
            child: const Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 15),
                Text('Se déconnecter', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---> NOUVEAU : Ajout du paramètre onTap pour rendre les lignes cliquables <---
  Widget _buildListItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: textGray, size: 24),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}