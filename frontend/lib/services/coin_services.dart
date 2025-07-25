// lib/services/coin_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinKey = 'user_coins';

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = await getCoins();
    await prefs.setInt(_coinKey, currentCoins + amount);
  }

  static Future<void> deductCoins(int amount) async {
  if (amount <= 0) return;
  
  final prefs = await SharedPreferences.getInstance();
  final currentCoins = await getCoins();
  final newBalance = currentCoins - amount;
  
  await prefs.setInt(_coinKey, newBalance >= 0 ? newBalance : 0);
}

  static Future<void> resetCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinKey, 0);
  }
}