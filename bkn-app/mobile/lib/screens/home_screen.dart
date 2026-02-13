import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/animate_fade.dart'; // Assurez-vous d'avoir créé ce fichier
import 'transfer_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'deposit_screen.dart'; // Import du nouvel écran de dépôt

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _usersList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    try {
      final me = await ApiService.getMe();
      final users = await ApiService.getUsers();
      setState(() {
        _user = me;
        _usersList = users;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond très légèrement gris pour le contraste
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bonjour, ${_user?['name'] ?? '...'}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Text("Bon retour !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)]),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            ),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. CARTE BANCAIRE (Animée délai 0ms) ---
                    AnimateFade(
                      delay: 0,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2962FF), Color(0xFF00B0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF2962FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Solde total", style: TextStyle(color: Colors.white70, fontSize: 16)),
                                Icon(Icons.nfc, color: Colors.white.withOpacity(0.5), size: 30),
                              ],
                            ),
                            // Compteur animé implicite (si le solde change, il change fluidement)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Text(
                                "${_user?['balance']} BKN",
                                key: ValueKey<int>(_user?['balance'] ?? 0), // Clé unique pour forcer l'anim quand la valeur change
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("@${_user?['username']}", style: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1)),
                                const Icon(Icons.credit_card, color: Colors.white70),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 2. ACTIONS RAPIDES (Animées délai 100ms) ---
                    AnimateFade(
                      delay: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAnimatedButton(Icons.history, "Historique", () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                          }),
                          
                          // BOUTON RECHARGER CONNECTÉ
                          _buildAnimatedButton(Icons.add, "Recharger", () async {
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen()));
                            if (result == true) _refreshData(); // Si le dépôt a réussi, on rafraîchit le solde
                          }),
                          
                          _buildAnimatedButton(Icons.qr_code, "Scanner", () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fonctionnalité à venir !")));
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 3. LISTE DES AMIS (Animée délai 200ms) ---
                    AnimateFade(
                      delay: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Envoyer de l'argent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _usersList.length,
                              itemBuilder: (context, index) {
                                final u = _usersList[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => TransferScreen(receiver: u)));
                                    if (result == true) _refreshData();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Hero( // Animation Hero : l'avatar "vole" vers l'écran suivant
                                          tag: "avatar_${u['id']}", // Tag unique requis
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                                            child: Text(u['name'][0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.primaries[index % Colors.primaries.length])),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(u['name'].split(" ")[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget bouton personnalisé avec effet de clic (InkWell)
  Widget _buildAnimatedButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Icon(icon, color: const Color(0xFF2962FF), size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}
