import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/constants.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const HackinderApp());
}

class HackinderApp extends StatelessWidget {
  const HackinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    ConnectionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.swipe),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined),
              label: 'Connections',
            ),
          ],
        ),
      ),
    );
  }
}