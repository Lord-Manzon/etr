import 'package:flutter/material.dart';
import 'db_helper.dart';

class PasswordProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _passwords = [];

  List<Map<String, dynamic>> get passwords => _passwords;

  Future<void> loadPasswords() async {
    _passwords = await DBHelper().getPasswords();
    notifyListeners();
  }

  Future<void> addPassword(Map<String, dynamic> data) async {
    await DBHelper().insertPassword(data);
    await loadPasswords();
  }

  Future<void> deletePassword(int id) async {
    await DBHelper().deletePassword(id);
    await loadPasswords();
  }

  Future<void> updatePassword(int id, Map<String, dynamic> data) async {
    await DBHelper().updatePassword(id, data);
    await loadPasswords();
  }
}
