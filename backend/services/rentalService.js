const Rental = require('../models/Rental');
const Item = require('../models/Item');
const Chat = require('../models/Chat');

class RentalService {
  static calculatePricing(item, startDateStr, endDateStr, freightType = 'pickup') {
    const start = new Date(startDateStr);
    const end = new Date(endDateStr);
    const diffTime = Math.abs(end - start);
    let daysCount = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    if (daysCount < 1) daysCount = 1;

    const dailyPrice = Number(item.daily_price);
    const subtotal = dailyPrice * daysCount;

    const discountAmount = daysCount >= 3 ? subtotal * 0.15 : 0.0;
    const baseForFee = subtotal - discountAmount;
    const serviceFee = Number((baseForFee * 0.10).toFixed(2));

    let freightCost = 0.0;
    if (freightType === 'hostDelivery') freightCost = 25.0;
    if (freightType === 'courier') freightCost = 35.0;

    const totalPrice = Number((baseForFee + serviceFee + freightCost).toFixed(2));
    const depositAmount = Number(item.deposit_amount);

    return {
      daysCount,
      dailyPrice,
      subtotal,
      discountAmount,
      serviceFee,
      freightType,
      freightCost,
      totalPrice,
      depositAmount
    };
  }

  static async createRental(renterUser, data) {
    const item = Item.findById(data.itemId);
    if (!item) {
      throw new Error('Equipamento não encontrado para locação.');
    }

    if (item.owner_id === renterUser.id) {
      throw new Error('Você não pode alugar o seu próprio equipamento.');
    }

    const pricing = this.calculatePricing(
      item,
      data.startDate,
      data.endDate,
      data.freightType || 'pickup'
    );

    const rentalId = `rent_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    const deliveryPin = Math.floor(100000 + Math.random() * 900000).toString();
    const returnPin = Math.floor(100000 + Math.random() * 900000).toString();

    const newRental = Rental.create({
      id: rentalId,
      item_id: item.id,
      renter_id: renterUser.id,
      host_id: item.owner_id,
      start_date: data.startDate,
      end_date: data.endDate,
      days_count: pricing.daysCount,
      daily_price: pricing.dailyPrice,
      subtotal: pricing.subtotal,
      discount_amount: pricing.discountAmount,
      service_fee: pricing.serviceFee,
      freight_type: pricing.freightType,
      freight_cost: pricing.freightCost,
      total_price: pricing.totalPrice,
      deposit_amount: pricing.depositAmount,
      payment_method: data.paymentMethod || 'creditCard',
      payment_status: 'paid',
      rental_status: 'paidConfirmed',
      delivery_pin: deliveryPin,
      return_pin: returnPin,
      escrow_status: 'held'
    });

    // Mensagem de boas-vindas do sistema no chat
    Chat.addMessage({
      id: `msg_${Date.now()}_sys`,
      rentalId: rentalId,
      senderId: 'sys_bot',
      senderName: 'AlugaTudo Sistema',
      senderType: 'system',
      message: `🎉 Reserva confirmada! Caução de R$ ${pricing.depositAmount.toFixed(2)} retida com segurança em custódia Escrow. Apresente o PIN [${deliveryPin}] na retirada física do equipamento.`
    });

    // Mensagem automática de saudação do anfitrião
    setTimeout(() => {
      try {
        Chat.addMessage({
          id: `msg_${Date.now()}_host`,
          rentalId: rentalId,
          senderId: item.owner_id,
          senderName: item.owner_name,
          senderType: 'host',
          message: `Olá ${renterUser.name}! Pagamento recebido com sucesso. Quando quiser combinar o horário exato de retirada ou tiver dúvidas sobre o equipamento, pode me responder por aqui.`
        });
      } catch (err) {
        console.error('Erro na mensagem auto do host:', err.message);
      }
    }, 500);

    return newRental;
  }

  static getRentalById(id) {
    const rental = Rental.findById(id);
    if (!rental) {
      throw new Error('Reserva não encontrada.');
    }
    return rental;
  }

  static getUserRentals(userId) {
    return Rental.findByUser(userId);
  }

  static verifyDeliveryPin(rentalId, enteredPin) {
    const rental = Rental.findById(rentalId);
    if (!rental) throw new Error('Reserva não encontrada.');

    if (rental.delivery_pin !== String(enteredPin).trim()) {
      throw new Error('PIN de entrega incorreto. Verifique o código de 6 dígitos gerado na confirmação.');
    }

    if (rental.rental_status !== 'paidConfirmed') {
      throw new Error(`A reserva já está no status '${rental.rental_status}'.`);
    }

    const updated = Rental.updateStatus(rentalId, 'inProgress');

    Chat.addMessage({
      id: `msg_${Date.now()}_pin`,
      rentalId,
      senderId: 'sys_bot',
      senderName: 'AlugaTudo Sistema',
      senderType: 'system',
      message: '✅ PIN de entrega validado com sucesso! Equipamento entregue ao locatário. O período de locação está oficialmente EM CURSO.'
    });

    return updated;
  }

  static completeRental(rentalId, enteredReturnPin = null) {
    const rental = Rental.findById(rentalId);
    if (!rental) throw new Error('Reserva não encontrada.');

    if (enteredReturnPin && rental.return_pin !== String(enteredReturnPin).trim()) {
      throw new Error('PIN de devolução incorreto.');
    }

    const updated = Rental.updateStatus(rentalId, 'completed', 'released');

    Chat.addMessage({
      id: `msg_${Date.now()}_complete`,
      rentalId,
      senderId: 'sys_bot',
      senderName: 'AlugaTudo Sistema',
      senderType: 'system',
      message: `🎉 Devolução concluída e vistoria aprovada! A caução de R$ ${rental.deposit_amount.toFixed(2)} foi totalmente estornada ao locatário.`
    });

    return updated;
  }
}

module.exports = RentalService;

