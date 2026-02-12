import 'package:flutter/material.dart';
import 'package:app_bkn/widgets/balance_card.dart';
import 'package:app_bkn/widgets/action_grid.dart';
import 'package:app_bkn/widgets/recent_transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    NewsScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
    BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Actus'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Félicité'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BKN',
          style: TextStyle(
            color: Color(0xFF0A2472),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, '/chatbot'),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0A2472),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// ==================== PAGE ACCUEIL ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BalanceCard(solde: 1500.0),
          const SizedBox(height: 24),
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2472),
            ),
          ),
          const SizedBox(height: 16),
          const ActionGrid(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2472),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Color(0xFF0A2472)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const RecentTransactions(),
        ],
      ),
    );
  }
}

// ==================== PAGE ACTUS ====================
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  final List<Map<String, dynamic>> news = const [
    {
      'title': 'Nouvelle fonctionnalité',
      'subtitle': 'Paiement par QR code disponible',
      'date': '10/02/2024',
    },
    {
      'title': 'Bonus de bienvenue',
      'subtitle': '100 BKN offerts pour toute inscription',
      'date': '08/02/2024',
    },
    {
      'title': 'Maintenance',
      'subtitle': 'Service indisponible de 02h à 04h',
      'date': '05/02/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: news.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2472).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.article, color: Color(0xFF0A2472)),
            ),
            title: Text(
              news[index]['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(news[index]['subtitle']!),
            trailing: Text(
              news[index]['date']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

// ==================== PAGE EVENTS ====================
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  final List<Map<String, dynamic>> events = const [
    {
      'title': 'Soirée étudiante',
      'subtitle': 'Paiement en BKN accepté',
      'date': '15/02/2024',
    },
    {
      'title': 'Concert',
      'subtitle': '-20% avec BKN',
      'date': '20/02/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C9A7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event, color: Color(0xFF00C9A7)),
            ),
            title: Text(
              events[index]['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(events[index]['subtitle']!),
            trailing: Text(
              events[index]['date']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

// ==================== PAGE PROFIL ====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Félicité - Profil',
        style: TextStyle(fontSize: 18, color: Color(0xFF0A2472)),
      ),
    );
  }
}