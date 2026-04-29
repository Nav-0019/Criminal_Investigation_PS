import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String fileName;
  final String risk;
  final String keyword;
  final int timestamp;
  final String location;
  final Map<String, dynamic> fullData;
  bool isReported;

  HistoryItem({
    required this.fileName,
    required this.risk,
    required this.keyword,
    required this.timestamp,
    required this.location,
    required this.fullData,
    this.isReported = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'risk': risk,
      'keyword': keyword,
      'timestamp': timestamp,
      'location': location,
      'fullData': fullData,
      'isReported': isReported,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      fileName: json['fileName'] ?? 'Unknown',
      risk: json['risk'] ?? 'LOW',
      keyword: json['keyword'] ?? 'General',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      location: json['location'] ?? 'Unknown',
      fullData: json['fullData'] ?? {},
      isReported: json['isReported'] ?? false,
    );
  }
}

class HistoryService {
  static const String _key = 'scan_history';

  static Future<void> saveHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList(_key) ?? [];
    
    // Add new item at the beginning
    historyJson.insert(0, jsonEncode(item.toJson()));
    
    // Limit history to 50 items to save space
    if (historyJson.length > 50) {
      historyJson = historyJson.sublist(0, 50);
    }
    
    await prefs.setStringList(_key, historyJson);
  }

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_key) ?? [];
    
    return historyJson.map((jsonStr) {
      return HistoryItem.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  static Future<void> markAsReported(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList(_key) ?? [];
    List<String> updated = [];
    
    for (var jsonStr in historyJson) {
      final item = HistoryItem.fromJson(jsonDecode(jsonStr));
      if (item.timestamp == timestamp) {
        item.isReported = true;
      }
      updated.add(jsonEncode(item.toJson()));
    }
    
    await prefs.setStringList(_key, updated);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
