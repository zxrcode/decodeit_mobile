class TimestampService {
  String toDate(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      int ts = int.parse(timestamp);
      // Handle both seconds and milliseconds (Unix vs JS timestamp)
      if (ts < 10000000000) {
        ts *= 1000;
      }
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      return date.toLocal().toString();
    } catch (e) {
      return 'Қате уақыт белгісі (Timestamp)';
    }
  }

  String toTimestamp(DateTime date) {
    return (date.millisecondsSinceEpoch ~/ 1000).toString();
  }
}
