import 'package:flutter/material.dart';

class CryptoWallet extends StatefulWidget {
  @override
  _CryptoWalletState createState() => _CryptoWalletState();
}

class _CryptoWalletState extends State<CryptoWallet> {
  double soldeEuros = 4520.0;
  double soldeBTC = 0.0;
  double coursBTC = 58432.0;

  void acheterBTC() {
    setState(() {
      if (soldeEuros >= 100) {
        soldeEuros -= 100;
        soldeBTC += 100 / coursBTC;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Achat réussi : +100€ en Bitcoin")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Solde insuffisant !")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Fond sombre spécial Crypto
      appBar: AppBar(
        title: Text("Yann's Crypto", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(
              "Votre portefeuille BTC",
              "${soldeBTC.toStringAsFixed(6)} BTC",
              Colors.orange,
            ),
            SizedBox(height: 15),
            _buildInfoCard(
              "Euros disponibles",
              "${soldeEuros.toStringAsFixed(2)} €",
              Colors.green,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Cours en direct : 1 BTC = $coursBTC €",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: acheterBTC,
              child: Text(
                "CONVERTIR 100€ EN BITCOIN",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String t, String v, Color c) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(t, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
          Text(
            v,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
