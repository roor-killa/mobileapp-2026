import 'package:flutter/material.dart';
import '../../main.dart'; // Import pour aller vers l'accueil après le code

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String codeSaisi = "";

  void _ajouterChiffre(String chiffre) {
    if (codeSaisi.length < 4) {
      setState(() => codeSaisi += chiffre);
      if (codeSaisi == "1234") {
        // TON CODE PIN SECRET
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BankHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002D5D), Color(0xFF001A35)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.yellow, size: 80),
              const SizedBox(height: 20),
              const Text(
                "BIENVENUE CHEZ YANN'S BANK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Saisissez votre code personnel",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Indicateurs de code (petits ronds)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: index < codeSaisi.length
                          ? Colors.yellow
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Pavé numérique chic
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children:
                      [
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "C",
                        "0",
                        "OK",
                      ].map((val) {
                        return InkWell(
                          onTap: () => val == "C"
                              ? setState(() => codeSaisi = "")
                              : _ajouterChiffre(val),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              val,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
