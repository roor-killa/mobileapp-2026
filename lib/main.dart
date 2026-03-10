import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/cards/card_customizer.dart';
import 'screens/education/training_list.dart';
import 'screens/crypto/crypto_wallet.dart';
import 'screens/games/ads_rewards.dart';
import 'screens/payments/facture_scan.dart';
import 'screens/virements/virement_main.dart';

void main() => runApp(const YannsBankApp());

class YannsBankApp extends StatelessWidget {
  const YannsBankApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF002D5D),
      ),
      home: const LoginScreen(),
    );
  }
}

class BankHomePage extends StatefulWidget {
  const BankHomePage({super.key});
  @override
  State<BankHomePage> createState() => _BankHomePageState();
}

class _BankHomePageState extends State<BankHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  double solde = 4520.0;
  bool aUneFacture = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: _selectedIndex == 0 ? _buildHomeBody() : _buildOtherScreens(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- DESIGN DU HEADER ET DES ONGLETS ---
  Widget _buildHomeBody() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: const Color(0xFF002D5D),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF002D5D), Color(0xFF0077BE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SOLDE TOTAL',
                      style: TextStyle(color: Colors.white70, letterSpacing: 2),
                    ),
                    Text(
                      '${solde.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.yellow,
            tabs: const [
              Tab(text: "Compte"),
              Tab(text: "Épargne"),
              Tab(text: "Crédits"),
              Tab(text: "Assurances"),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMainTransactionList(),
          _buildGenericTab("MON ÉPARGNE", [
            _item("Livret A", "2 500,45 €", Icons.savings, Colors.orange),
            _item("PEL", "12 000,00 €", Icons.account_balance, Colors.blue),
          ]),
          _buildGenericTab("MES CRÉDITS", [
            _item("Prêt Étudiant", "- 8 450,00 €", Icons.school, Colors.red),
          ]),
          _buildGenericTab("MES ASSURANCES", [
            _item("Habitation", "Active", Icons.home, Colors.green),
          ]),
        ],
      ),
    );
  }

  Widget _buildMainTransactionList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "SERVICES PREMIUM",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildQuickBtn(
              "Crypto",
              Icons.currency_bitcoin,
              Colors.orange,
              CryptoWallet(),
            ),
            const SizedBox(width: 15),
            _buildQuickBtn(
              "Gagner \$",
              Icons.ads_click,
              Colors.green,
              const AdsRewards(),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _buildCategoryHeader("MES PAIEMENTS", Icons.payment),
        _buildBox([
          _item("Restaurant", "- 35,00 €", Icons.restaurant, Colors.orange),
          _item("Vêtements", "- 89,90 €", Icons.shopping_bag, Colors.blue),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FactureScan()),
            ).then((_) => setState(() => aUneFacture = false)),
            child: _item(
              "Facture EDF",
              aUneFacture ? "À PAYER" : "PAYÉ",
              Icons.qr_code_scanner,
              Colors.yellow,
            ),
          ),
        ]),
        const SizedBox(height: 30),
        _buildCategoryHeader("MES ABONNEMENTS", Icons.sync),
        _buildBox([
          _item("Netflix", "- 13,99 €", Icons.movie, Colors.red),
          _item("Spotify", "- 9,99 €", Icons.music_note, Colors.green),
          _item("Canal+", "- 25,00 €", Icons.tv, Colors.white),
        ]),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF001A35),
      selectedItemColor: Colors.yellow,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Comptes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Virements',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartes'),
        BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Plus'),
      ],
    );
  }

  Widget _buildOtherScreens() {
    switch (_selectedIndex) {
      case 1:
        return const VirementMain();
      case 2:
        return const CardCustomizer();
      case 3:
        return _buildContactsPage();
      case 4:
        return _buildPlusPage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildQuickBtn(String t, IconData i, Color c, Widget p) {
    return Expanded(
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) => p)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(i, color: c, size: 30),
              const SizedBox(height: 8),
              Text(
                t,
                style: TextStyle(color: c, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBox(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: items),
    );
  }

  Widget _item(String t, String a, IconData i, Color c) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: c.withOpacity(0.1),
        child: Icon(i, color: c, size: 18),
      ),
      title: Text(
        t,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      trailing: Text(a, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGenericTab(String title, List<Widget> items) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildBox(items),
      ],
    );
  }

  Widget _buildContactsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "MES CONTACTS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildBox([
          _item("Willy Bod", "Bénéficiaire", Icons.person, Colors.blue),
          _item("Maman", "Famille", Icons.favorite, Colors.pink),
        ]),
      ],
    );
  }

  Widget _buildPlusPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            "Yannelle Negui",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 40),
        _buildBox([
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text("Partager mon RIB / IBAN"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ RIB copié ! Prêt à être partagé."),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          _item(
            "Mes Documents",
            "RIB, Attestations",
            Icons.file_copy,
            Colors.grey,
          ),
          _item("Sécurité", "Code PIN", Icons.lock, Colors.orange),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ]),
      ],
    );
  }
} // <--- Tout est bien fermé maintenant !
