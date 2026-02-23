class HistoryItem {
  final String title;
  final String details;
  final DateTime timestamp;
  final String type; // e.g., 'QR', 'Hash', 'Encode', 'Decode'

  HistoryItem({
    required this.title,
    required this.details,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        title: json['title'],
        details: json['details'],
        timestamp: DateTime.parse(json['timestamp']),
        type: json['type'],
      );
}
