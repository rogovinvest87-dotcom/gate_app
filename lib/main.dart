import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/guest_access_screen.dart';
import 'screens/event_log_screen.dart';
import 'screens/automation_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const GateApp());
}

class GateApp extends StatelessWidget {
  const GateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MqttService>(
      create: (_) => MqttService(),
      child: MaterialApp(
        title: 'Управление воротами',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GuestAccessScreen(),
    const EventLogScreen(),
    const AutomationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Гости',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_mode),
            label: 'Авто',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настр.',
          ),
        ],
      ),
    );
  }
}
