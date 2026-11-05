const Chat = require('../models/Chat');
const Rental = require('../models/Rental');

class ChatService {
  static getMessages(rentalId) {
    const rental = Rental.findById(rentalId);
    if (!rental) throw new Error('Reserva não encontrada.');
    return Chat.getMessages(rentalId);
  }

  static sendMessage(user, rentalId, text) {
    if (!text || text.trim().length === 0) {
      throw new Error('O conteúdo da mensagem não pode estar vazio.');
    }

    const rental = Rental.findById(rentalId);
    if (!rental) throw new Error('Reserva não encontrada.');

    const isHost = user.id === rental.host_id;
    const senderType = isHost ? 'host' : 'user';

    const msgId = `msg_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    const newMsg = Chat.addMessage({
      id: msgId,
      rentalId,
      senderId: user.id,
      senderName: user.name,
      senderType,
      message: text.trim()
    });

    // Resposta contextual automatizada se o usuário perguntar sobre horário ou entrega
    if (senderType === 'user') {
      const lower = text.toLowerCase();
      setTimeout(() => {
        try {
          let hostReply = null;
          if (lower.includes('horário') || lower.includes('horas') || lower.includes('chegar')) {
            hostReply = 'Perfeito! Qualquer horário entre as 09h e as 18h fica ótimo para mim no local combinado.';
          } else if (lower.includes('pin') || lower.includes('código')) {
            hostReply = 'Pode me fornecer o PIN de 6 dígitos no momento da entrega para registrarmos no app!';
          } else if (lower.includes('câmera') || lower.includes('bateria') || lower.includes('manual')) {
            hostReply = 'Já deixei todas as baterias carregadas a 100% e o manual em PDF salvo!';
          }

          if (hostReply) {
            Chat.addMessage({
              id: `msg_${Date.now()}_auto`,
              rentalId,
              senderId: rental.host_id,
              senderName: rental.host_name,
              senderType: 'host',
              message: hostReply
            });
          }
        } catch (err) {
          console.error('Erro na resposta auto:', err.message);
        }
      }, 1200);
    }

    return newMsg;
  }

  static addInspectionPhoto(user, rentalId, { title, photoUrl, step = 'pre_delivery' }) {
    if (!photoUrl) throw new Error('URL da foto é obrigatória.');

    const id = `insp_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    const insp = Chat.addInspectionPhoto({
      id,
      rentalId,
      uploadedBy: user.id,
      step,
      title: title || 'Foto de Vistoria',
      photoUrl
    });

    // Adiciona card no chat
    Chat.addMessage({
      id: `msg_${Date.now()}_insp`,
      rentalId,
      senderId: user.id,
      senderName: user.name,
      senderType: 'inspectionCard',
      message: `📸 Nova foto de vistoria adicionada: "${title || 'Registro de Conformidade'}"`,
      photoUrls: [photoUrl]
    });

    return insp;
  }
}

module.exports = ChatService;

