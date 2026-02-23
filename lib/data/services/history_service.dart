import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/history_item.dart';

class HistoryService {
  static const String _key = 'history_items';

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_key) ?? [];
    return jsonStringList
        .map((jsonString) => HistoryItem.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = await getHistory();
    
    // Add new item to the beginning
    currentHistory.insert(0, item);
    
    // Keep only the last 10 items
    if (currentHistory.length > 10) {
      currentHistory.removeLast();
    }
    
    final jsonStringList = currentHistory
        .map((item) => jsonEncode(item.toJson()))
        .toList();
        
    await prefs.setStringList(_key, jsonStringList);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
