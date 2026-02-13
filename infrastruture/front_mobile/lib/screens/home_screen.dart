import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'history_screen.dart'; // N'oubliez pas d'importer l'écran historique

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? myProfile;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    try {
      final me = await ApiService.getMe(widget.token);
      final list = await ApiService.getUsers(widget.token);
      setState(() {
        myProfile = me;
        users = list;
      });
    } catch (e) {
      print(e); // Gérer l'erreur (ex: token expiré)
    }
  }

  void sendMoney(String receiverUsername) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Envoyer à $receiverUsername"),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Montant (BKN)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.transfer(
                    widget.token, receiverUsername, int.parse(amountCtrl.text));
                refreshData(); // Mettre à jour le solde après envoi
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Envoyé avec succès ! 💸")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de l'envoi ❌")));
              }
            },
            child: const Text("Valider"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour ${myProfile!['username']}"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Bouton Historique
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    token: widget.token,
                    myUsername: myProfile!['username'],
                  ),
                ),
              );
            },
          ),
          // Bouton Déconnexion
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Se déconnecter',
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte Solde
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text("SOLDE DISPONIBLE",
                    style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(
                  "${myProfile!['balance']} BKN",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Envoyer de l'argent à...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctx, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      users[i]['username'][0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                  title: Text(users[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("@${users[i]['username']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.send, color: Colors.indigo),
                    onPressed: () => sendMoney(users[i]['username']),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
