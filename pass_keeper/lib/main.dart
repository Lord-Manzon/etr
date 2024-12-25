import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'password_provider.dart';
import 'screens/password_list_screen.dart';
import 'screens/password_generator_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize plugin for Android
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings);

  runApp(const PassKeeperApp());
}

class PassKeeperApp extends StatelessWidget {
  const PassKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PasswordProvider()..loadPasswords(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PassKeeper',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PassKeeperHome(),
      ),
    );
  }
}

class PassKeeperHome extends StatefulWidget {
  const PassKeeperHome({super.key});

  @override
  State<PassKeeperHome> createState() => _PassKeeperHomeState();
}

class _PassKeeperHomeState extends State<PassKeeperHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PasswordListScreen(),
    const PasswordGeneratorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Passwords',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.password),
            label: 'Generate Password',
          ),
        ],
      ),
    );
  }
}
