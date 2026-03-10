import 'package:flutter/material.dart';

class CardCustomizer extends StatefulWidget {
  const CardCustomizer({super.key});
  @override
  State<CardCustomizer> createState() => _CardCustomizerState();
}

class _CardCustomizerState extends State<CardCustomizer> {
  Color _cardColor = const Color(0xFF0077BE);
  double _hue = 200.0;
  String _selectedTexture = "Lisse";
  String _nomCarte = "Yannelle Negui";

  BoxDecoration _buildCardDecoration() {
    if (_selectedTexture == "Métal") {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[700]!, Colors.grey[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (_selectedTexture == "Carbone") {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        gradient: const LinearGradient(
          colors: [Colors.black87, Colors.black, Colors.grey],
        ),
      );
    } else if (_selectedTexture == "Marbre") {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [_cardColor, Colors.white.withOpacity(0.4), _cardColor],
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: _cardColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text("Design de ma Carte"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // APERÇU DE LA CARTE
            Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1.58,
                child: Container(
                  decoration: _buildCardDecoration().copyWith(
                    boxShadow: [
                      BoxShadow(
                        color: _cardColor.withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 40,
                        left: 30,
                        child: Container(
                          width: 50,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 30,
                        child: Text(
                          _nomCarte.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 30,
                        left: 30,
                        child: Text(
                          "**** **** **** 2026",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const Positioned(
                        top: 30,
                        right: 30,
                        child: Icon(Icons.contactless, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // PERSONNALISATION
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF001A35),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Nom sur la carte",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    onChanged: (v) => setState(() => _nomCarte = v),
                  ),
                  const SizedBox(height: 20),
                  const Text("COULEUR PERSONNALISÉE"),
                  Slider(
                    value: _hue,
                    min: 0,
                    max: 360,
                    activeColor: HSVColor.fromAHSV(1, _hue, 0.8, 0.8).toColor(),
                    onChanged: (v) => setState(() {
                      _hue = v;
                      _cardColor = HSVColor.fromAHSV(
                        1,
                        _hue,
                        0.7,
                        0.6,
                      ).toColor();
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _textureBtn("Lisse", Icons.format_color_fill),
                      _textureBtn("Métal", Icons.settings_brightness),
                      _textureBtn("Marbre", Icons.blur_on),
                      _textureBtn("Carbone", Icons.grid_4x4),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "VALIDER LE DESIGN",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textureBtn(String n, IconData i) {
    bool s = _selectedTexture == n;
    return InkWell(
      onTap: () => setState(() => _selectedTexture = n),
      child: Column(
        children: [
          Icon(i, color: s ? Colors.yellow : Colors.white),
          Text(
            n,
            style: TextStyle(
              color: s ? Colors.yellow : Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
