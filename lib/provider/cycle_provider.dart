import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  bool get isMenstruating => _isMenstruating;

  Future<void> loadCycleStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isMenstruating = prefs.getBool('isMenstruating') ?? false;
    notifyListeners();
  }

  Future<void> startCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = '${dotenv.env['API_URL']}/cycles/start';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Siklus dimulai');
    if (response.statusCode == 200 || response.statusCode == 201) {
      _isMenstruating = true;
      await prefs.setBool('isMenstruating', true);
      notifyListeners();
    } else {
      throw Exception('Gagal memulai siklus');
    }
  }

  Future<void> endCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = '${dotenv.env['API_URL']}/cycles/finish';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _isMenstruating = false;
      await prefs.setBool('isMenstruating', false);
      notifyListeners();
    } else {
      throw Exception('Gagal mengakhiri siklus');
    }
  }
}
