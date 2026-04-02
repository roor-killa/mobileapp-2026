import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'my_qr_code_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  double solde = 0;

  @override
  void initState() {
    super.initState();
    loadSolde();
  }

  void loadSolde() async {
    double s = await api.getSolde();
    print('Solde récupéré : $s'); // debug
    setState(() {
      solde = s;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Accueil')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Solde : $solde €', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Ici on récupère l'ID de l'utilisateur depuis l'API ou le stockage
              int currentUserId = 1; // temporaire, à remplacer par ton user ID réel
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyQRCodeScreen(userId: currentUserId),
                ),
              );
            },
            child: Text('Mon QR Code'),
          ),
        ],
      ),
    ),
  );
}