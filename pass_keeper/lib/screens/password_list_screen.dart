import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../password_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _searchQuery = '';
  String _selectedCategory = 'All'; // Default to "All"

  final Map<String, IconData> _categoryIcons = {
    'Personal': Icons.person,
    'Work': Icons.work,
    'School': Icons.school,
    'Others': Icons.more_horiz,
    'All': Icons.all_inbox, // All category icon
  };

  final Map<String, Color> _categoryColors = {
    'Personal': Colors.blue,
    'Work': Colors.yellow,
    'School': Colors.green,
    'Others': Colors.purple,
    'All': Colors.grey, // Color for "All"
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      // Permission granted, proceed with scheduling notifications
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission granted')),
      );
    } else if (status.isDenied) {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied')),
      );
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  Future<void> _scheduleNotification(int intervalDays) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'password_channel',
      'Password Notifications',
      channelDescription: 'Reminder to update your passwords',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0, // Notification ID
      'Password Reminder',
      'It\'s time to update your passwords!',
      RepeatInterval
          .values[(intervalDays ~/ 7) - 1], // Convert days to interval
      details,
      androidScheduleMode: AndroidScheduleMode.exact, // Required parameter
    );
  }

  void _showNotificationSettings() async {
    await _requestNotificationPermission();

    // Only proceed if the user has granted permission
    if (await Permission.notification.isGranted) {
      int selectedDays = 7; // Default reminder interval
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'How often should I remind you to change your password?'),
                DropdownButtonFormField<int>(
                  value: selectedDays,
                  items: [7, 14, 30]
                      .map((days) => DropdownMenuItem(
                          value: days, child: Text('$days days')))
                      .toList(),
                  onChanged: (value) {
                    selectedDays = value!;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _scheduleNotification(selectedDays);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Reminder set for every $selectedDays days!')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PasswordProvider>(context);
    List<Map<String, dynamic>> passwords = provider.passwords;

    // Filter passwords based on the selected category
    if (_selectedCategory != 'All') {
      passwords = passwords
          .where((password) => password['category'] == _selectedCategory)
          .toList();
    }

    // Filter passwords based on the search query
    passwords = passwords
        .where((password) =>
            password['username']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            password['category']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotificationSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Category buttons: All, Personal, Work, School, Others
                  ...['All', 'Personal', 'Work', 'School', 'Others']
                      .map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == category
                              ? Colors.blue
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcons[category],
                              color: _categoryColors[category],
                            ),
                            const SizedBox(width: 5),
                            Text(
                              category,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Expanded(
            child: passwords.isEmpty
                ? Center(
                    child: Text(
                      'No passwords found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      return Dismissible(
                        key: ValueKey(password['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this password?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          provider.deletePassword(password['id']);
                        },
                        child: ListTile(
                          leading: Icon(
                            _categoryIcons[password['category']] ??
                                Icons.more_horiz,
                            color: _categoryColors[password['category']],
                          ),
                          title: Text(
                            password['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(password['category']),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: password['password']),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Password copied!')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
