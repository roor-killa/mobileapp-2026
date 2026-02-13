import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BknApp());
}

class BknApp extends StatelessWidget {
  const BknApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BKN App',
      debugShowCheckedModeBanner: false,
      
      // --- THÈME MODERNE ---
      theme: ThemeData(
        useMaterial3: true,
        
        // Palette de couleurs principale (Bleu roi moderne)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2962FF), 
          primary: const Color(0xFF2962FF),
          secondary: const Color(0xFF00B0FF),
          brightness: Brightness.light,
        ),
        
        // Fond blanc par défaut pour un look épuré
        scaffoldBackgroundColor: Colors.white,
        
        // Police moderne (nécessite le package google_fonts)
        textTheme: GoogleFonts.poppinsTextTheme(), 
        
        // Style des champs de saisie (Arrondis, fond gris clair)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2962FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIconColor: Colors.grey[600],
        ),
        
        // Style des boutons (Gros, arrondis, bleu)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        // Style de la barre d'application
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Texte noir
          elevation: 0,
          centerTitle: true,
        ),
      ),
      
      // Page de démarrage
      home: const LoginScreen(),
    );
  }
}
