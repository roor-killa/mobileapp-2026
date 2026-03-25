import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../announcements/announcements_screen.dart';
import '../announcements/create_announcement_screen.dart';
import '../chatbot/chat_screen.dart';
import '../events/events_screen.dart';
import '../events/create_event_screen.dart';
import '../messages/conversations_screen.dart';
import '../messages/search_users_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  final _screens = const [
    AnnouncementsScreen(),
    EventsScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFabs(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 32,
          child: NavigationBar(
            height: 65,
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) {
              setState(() => _currentIndex = i);
              _fabController.reset();
              _fabController.forward();
            },
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(
                icon: _buildAnimatedIcon(Icons.announcement_outlined, 0),
                selectedIcon: _buildAnimatedIcon(Icons.announcement, 0,
                    color: Theme.of(context).primaryColor),
                label: 'Annonces',
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(Icons.event_outlined, 1),
                selectedIcon: _buildAnimatedIcon(Icons.event, 1,
                    color: Theme.of(context).primaryColor),
                label: 'Événements',
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(Icons.chat_bubble_outline, 2),
                selectedIcon: _buildAnimatedIcon(Icons.chat_bubble, 2,
                    color: Theme.of(context).primaryColor),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(Icons.person_outline, 3),
                selectedIcon: _buildAnimatedIcon(Icons.person, 3,
                    color: Theme.of(context).primaryColor),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chatbot FAB (always visible)
          FloatingActionButton.small(
            heroTag: 'chatbot',
            onPressed: () async {
              final tabIndex = await Navigator.push<int>(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
              if (tabIndex != null && mounted) {
                setState(() => _currentIndex = tabIndex);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          // Action FAB (context-dependent)
          if (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2) ...[
            const SizedBox(height: 12),
            if (_currentIndex == 0)
              FloatingActionButton.extended(
                heroTag: 'create_announcement',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateAnnouncementScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Publier'),
                elevation: 4,
              ),
            if (_currentIndex == 1)
              FloatingActionButton.extended(
                heroTag: 'create_event',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateEventScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Créer'),
                elevation: 4,
              ),
            if (_currentIndex == 2)
              FloatingActionButton.extended(
                heroTag: 'search_users',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchUsersScreen()),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Ajouter'),
                elevation: 4,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index, {Color? color}) {
    return AnimatedScale(
      scale: _currentIndex == index ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _currentIndex == index ? 1.0 : 0.7,
        child: Icon(icon),
      ),
    );
  }
}
