import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'login_screen.dart'; // N'oublie pas d'importer ton écran de connexion ici !

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

  // On récupère les vraies infos de l'utilisateur sauvegardées lors de la connexion
  Future<void> _chargerProfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom = prefs.getString('name') ?? "Leina MUSARAGANYI"; 
      _email = prefs.getString('email') ?? "mtleina@gmail.com";
      _initiale = _nom.isNotEmpty ? _nom[0].toUpperCase() : "B";
    });
  }

  // Logique de déconnexion
  Future<void> _seDeconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // On supprime le token et les infos
    
    if (!mounted) return;
    
    // Remplace "LoginScreen" par le vrai nom de ta page de connexion
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Prend 85% de l'écran
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- EN-TÊTE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: textGray),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // --- SECTION PROFIL ---
          const Text(
            'PROFIL',
            style: TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: zinc700),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: emerald500, shape: BoxShape.circle),
                  child: Center(
                    child: Text(_initiale, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
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

          // --- SECTION SÉCURITÉ ---
          const Text(
            'SÉCURITÉ',
            style: TextStyle(color: textGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          _buildListItem(Icons.settings_outlined, "Modifier le mot de passe"),
          _buildListItem(Icons.person_outline, "Vérification d'identité"),
          
          const SizedBox(height: 20),
          const Divider(color: zinc700),
          const SizedBox(height: 20),

          // --- BOUTON DÉCONNEXION ---
          GestureDetector(
            onTap: _seDeconnecter, // Appelle la fonction de déconnexion
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.redAccent),
                const SizedBox(width: 15),
                const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour les lignes du menu
  Widget _buildListItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: textGray, size: 24),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}