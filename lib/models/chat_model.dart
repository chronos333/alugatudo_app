enum MessageType {
  user,
  host,
  system,
  inspectionCard,
}

class ChatMessage {
  final String id;
  final MessageType type;
  final String senderName;
  final String? senderInitials;
  final String text;
  final DateTime timestamp;
  final bool isDelivered;
  final bool isRead;
  final List<String>? photoUrls;

  ChatMessage({
    required this.id,
    required this.type,
    required this.senderName,
    this.senderInitials,
    required this.text,
    required this.timestamp,
    this.isDelivered = true,
    this.isRead = true,
    this.photoUrls,
  });
}
