import 'package:flutter/material.dart';

void main() {
  runApp(const MonApplicationLicence());
}

class MonApplicationLicence extends StatelessWidget {
  const MonApplicationLicence({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617), // Couleur sombre style "Espace"
        cardColor: const Color(0xFF1E293B), // Gris bleuté pour les cartes
        primaryColor: Colors.blueAccent,
      ),
      home: const PageAccueilLicence(),
    );
  }
}

class PageAccueilLicence extends StatelessWidget {
  const PageAccueilLicence({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar transparente pour laisser voir le fond
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Licence Informatique', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        // Fond dégradé pour imiter l'effet "Espace/Galaxie"
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020617), // Noir/Bleu très foncé
              Color(0xFF172554), // Bleu nuit
              Color(0xFF020617),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
          children: [
            // --- SECTION TITRE ---
            const Center(
              child: Icon(Icons.school_rounded, size: 80, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              "Devenez un expert du numérique",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Une formation complète du développement web à l'intelligence artificielle.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 40),

            // --- SECTION ATOUTS (Cartes) ---
            const SectionTitle(title: "Pourquoi nous choisir ?"),
            const InfoCard(
              icon: Icons.code,
              title: "Développement",
              description: "Maîtrisez Java, Python, Web, Mobile (Flutter !).",
            ),
            const InfoCard(
              icon: Icons.storage,
              title: "Data & IA",
              description: "Bases de données, Big Data et Machine Learning.",
            ),
            const InfoCard(
              icon: Icons.security,
              title: "Cybersécurité",
              description: "Apprenez à sécuriser les réseaux et les systèmes.",
            ),

            const SizedBox(height: 30),

            // --- SECTION DÉBOUCHÉS ---
            const SectionTitle(title: "Les Débouchés"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  JobItem(text: "Développeur Fullstack"),
                  JobItem(text: "Ingénieur Logiciel"),
                  JobItem(text: "Data Analyst"),
                  JobItem(text: "Chef de projet Tech"),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- BOUTON D'ACTION ---
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Télécharger la brochure", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PERSONNALISÉS POUR SIMPLIFIER LE CODE ---

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoCard({super.key, required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }
}

class JobItem extends StatelessWidget {
  final String text;
  const JobItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
