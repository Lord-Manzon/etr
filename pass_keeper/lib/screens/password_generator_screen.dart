import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../password_provider.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _selectedCategory = 'Personal'; // Default category
  final List<String> _categories = ['Personal', 'Work', 'School', 'Others'];

  String generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+';
    final rand = Random();
    return List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PasswordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _passwordController.text = generatePassword();
                });
              },
              child: const Text('Generate'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_usernameController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields!'),
                    ),
                  );
                  return;
                }

                provider.addPassword({
                  'username': _usernameController.text,
                  'password': _passwordController.text,
                  'category': _selectedCategory,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password saved!')),
                );

                // Clear fields after saving
                _usernameController.clear();
                _passwordController.clear();
                setState(() {
                  _selectedCategory = 'Personal';
                });
              },
              child: const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
