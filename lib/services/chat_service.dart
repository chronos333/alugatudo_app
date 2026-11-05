import '../models/chat_model.dart';
import 'mock_data_service.dart';

class ChatService {
  final List<ChatMessage> _messages = List.from(MockDataService.getInitialMessages());

  List<ChatMessage> getMessages() {
    return List.unmodifiable(_messages);
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.user,
      senderName: 'Você',
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(msg);
  }

  void addInspectionPhotoMessage() {
    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.user,
      senderName: 'Você',
      text: '📷 [Simulação de Vistoria]: Foto de entrega anexada com carimbo de geolocalização e hash temporal.',
      timestamp: DateTime.now(),
    );

    _messages.add(msg);
  }

  void addHostResponse(String reply) {
    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.host,
      senderName: 'Lucas M.',
      senderInitials: 'LM',
      text: reply,
      timestamp: DateTime.now(),
    );

    _messages.add(msg);
  }
}
