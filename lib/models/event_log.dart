class EventLogEntry {
  final String topic;
  final String message;
  final DateTime timestamp;

  EventLogEntry({
    required this.topic,
    required this.message,
    required this.timestamp,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
