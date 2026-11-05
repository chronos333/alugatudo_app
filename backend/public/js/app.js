/**
 * AlugaTudo — Core Frontend Client Application
 * Conexão direta com a API REST MVC (SQLite)
 */

class AlugaTudoApp {
  constructor() {
    this.apiBase = '/api/v1';
    this.currentUser = null;
    this.token = localStorage.getItem('alugatudo_token') || null;
    this.activeUserId = localStorage.getItem('alugatudo_user_id') || 'usr_001';

    // State
    this.items = [];
    this.selectedItem = null;
    this.selectedCategory = 'Todas';
    this.selectedRadius = 5.0;
    this.searchQuery = '';
    this.viewMode = 'grid';

    // Checkout State
    this.checkoutFreight = 'pickup';
    this.checkoutPaymentMethod = 'creditCard';
    this.calculatedRentalPricing = null;

    // Chat State
    this.activeRental = null;
    this.chatInterval = null;

    this.init();
  }

  async init() {
    this.setupEventListeners();
    await this.loadUserProfile();
    await this.loadItems();
    this.initDates();
  }

  getHeaders() {
    const headers = { 'Content-Type': 'application/json' };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    if (this.activeUserId) {
      headers['X-User-Id'] = this.activeUserId;
    }
    return headers;
  }

  setupEventListeners() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
      let debounce = null;
      searchInput.addEventListener('input', (e) => {
        clearTimeout(debounce);
        debounce = setTimeout(() => {
          this.searchQuery = e.target.value.trim();
          this.loadItems();
        }, 300);
      });
    }
  }

  initDates() {
    const today = new Date();
    const tomorrow = new Date();
    tomorrow.setDate(today.getDate() + 3);

    const startInput = document.getElementById('rentalStartDate');
    const endInput = document.getElementById('rentalEndDate');

    if (startInput && endInput) {
      startInput.value = today.toISOString().split('T')[0];
      endInput.value = tomorrow.toISOString().split('T')[0];
    }
  }

  // ==========================================
  // USUÁRIO & AUTH
  // ==========================================
  async loadUserProfile() {
    try {
      const res = await fetch(`${this.apiBase}/auth/me`, { headers: this.getHeaders() });
      const data = await res.json();
      if (data.success && data.data?.user) {
        this.currentUser = data.data.user;
        this.renderUserBadge();
      }
    } catch (err) {
      console.warn('Erro ao carregar perfil do usuário:', err);
    }
  }

  renderUserBadge() {
    if (!this.currentUser) return;
    document.getElementById('userName').textContent = this.currentUser.name;
    document.getElementById('userAvatar').src = this.currentUser.avatar_url;

    const kycBadge = document.getElementById('userKycBadge');
    if (this.currentUser.kyc_status === 'approved') {
      kycBadge.innerHTML = '<i class="fa-solid fa-circle-check"></i> KYC Aprovado';
      kycBadge.style.color = 'var(--color-primary)';
    } else {
      kycBadge.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> KYC Pendente';
      kycBadge.style.color = '#D97706';
    }

    // Render perfil page
    document.getElementById('profileCardName').textContent = this.currentUser.name;
    document.getElementById('profileCardEmail').textContent = this.currentUser.email;
    document.getElementById('profileCardAvatar').src = this.currentUser.avatar_url;
    document.getElementById('profileRentalsCount').textContent = this.currentUser.completed_rentals;
    document.getElementById('profileRating').textContent = `${this.currentUser.rating.toFixed(1)} ★`;

    const profileKycBox = document.getElementById('profileKycStatusBox');
    if (this.currentUser.kyc_status === 'approved') {
      profileKycBox.innerHTML = `
        <span style="background: #ECFDF5; color: #065F46; padding: 4px 12px; border-radius: 9999px; font-size: 0.8rem; font-weight: 700;">
          <i class="fa-solid fa-circle-check"></i> Identidade Verificada (KYC Aprovado)
        </span>
      `;
    } else {
      profileKycBox.innerHTML = `
        <span style="background: #FEF3C7; color: #92400E; padding: 4px 12px; border-radius: 9999px; font-size: 0.8rem; font-weight: 700;">
          <i class="fa-solid fa-triangle-exclamation"></i> Verificação de Identidade Pendente
        </span>
      `;
    }
  }

  async switchUser(userId) {
    this.activeUserId = userId;
    localStorage.setItem('alugatudo_user_id', userId);
    await this.loadUserProfile();
    await this.loadItems();
    this.showToast(`Usuário alternado com sucesso para ${this.currentUser?.name}!`);
  }

  // ==========================================
  // CATÁLOGO & ITENS
  // ==========================================
  async loadItems() {
    try {
      const params = new URLSearchParams();
      if (this.selectedCategory && this.selectedCategory !== 'Todas') {
        params.append('category', this.selectedCategory);
      }
      if (this.searchQuery) {
        params.append('query', this.searchQuery);
      }
      if (this.selectedRadius) {
        params.append('maxRadius', this.selectedRadius);
      }

      const res = await fetch(`${this.apiBase}/items?${params.toString()}`, { headers: this.getHeaders() });
      const data = await res.json();

      if (data.success) {
        this.items = data.data.items || [];
        this.renderItems();
      }
    } catch (err) {
      this.showToast('Erro ao carregar equipamentos: ' + err.message, 'error');
    }
  }

  renderItems() {
    const grid = document.getElementById('itemsGrid');
    const countBadge = document.getElementById('itemsCountBadge');
    countBadge.textContent = `${this.items.length} equipamentos encontrados`;

    if (this.items.length === 0) {
      grid.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: white; border-radius: 16px; border: 1px dashed var(--color-outline);">
          <i class="fa-solid fa-box-open" style="font-size: 3rem; color: var(--color-outline); margin-bottom: 12px;"></i>
          <h3 style="font-weight: 700;">Nenhum equipamento encontrado</h3>
          <p style="color: var(--color-on-surface-variant); font-size: 0.9rem;">Tente ajustar seus filtros de categoria ou ampliar o raio de distância.</p>
        </div>
      `;
      return;
    }

    grid.innerHTML = this.items.map(item => {
      const imgUrl = item.images && item.images.length > 0 ? item.images[0] : 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80';
      return `
        <div class="item-card" onclick="app.openDetailModal('${item.id}')">
          <div class="card-image-box">
            <img src="${imgUrl}" alt="${item.title}" class="card-image" loading="lazy">
            <div class="escrow-badge">
              <i class="fa-solid fa-shield-halved"></i> Caução Garantida
            </div>
            <button class="fav-btn" onclick="event.stopPropagation(); app.toggleFavorite('${item.id}')" title="Favoritar">
              <i class="fa-solid fa-heart"></i>
            </button>
            <div class="distance-badge">
              <i class="fa-solid fa-location-dot"></i> ${item.distance_label || item.distance_km + ' km'}
            </div>
          </div>
          <div class="card-body">
            <div class="card-category">${item.category}</div>
            <h3 class="card-title">${item.title}</h3>
            <p class="card-desc">${item.description}</p>
            <div class="card-footer">
              <div class="price-box">
                <span class="price-label">Diária a partir de</span>
                <div>
                  <span class="price-value">R$ ${item.daily_price.toFixed(2).replace('.', ',')}</span>
                  <span class="price-unit">/dia</span>
                </div>
              </div>
              <div class="host-mini">
                <img src="${item.owner_avatar || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80'}" class="host-mini-avatar">
                <span class="host-rating"><i class="fa-solid fa-star star-icon"></i> ${item.owner_rating ? item.owner_rating.toFixed(1) : '5.0'}</span>
              </div>
            </div>
          </div>
        </div>
      `;
    }).join('');
  }

  setCategory(category) {
    this.selectedCategory = category;
    const chips = document.querySelectorAll('#categoryChips .chip');
    chips.forEach(chip => {
      if (chip.textContent.includes(category) || (category === 'Todas' && chip.textContent.trim() === 'Todas')) {
        chip.classList.add('active');
      } else {
        chip.classList.remove('active');
      }
    });
    this.loadItems();
  }

  setRadius(val) {
    this.selectedRadius = Number(val);
    document.getElementById('radiusLabel').textContent = `${val} km`;
    this.loadItems();
  }

  setViewMode(mode) {
    this.viewMode = mode;
    const grid = document.getElementById('itemsGrid');
    const btnGrid = document.getElementById('viewGridBtn');
    const btnList = document.getElementById('viewListBtn');

    if (mode === 'list') {
      grid.style.gridTemplateColumns = '1fr';
      btnList.classList.add('active');
      btnGrid.classList.remove('active');
    } else {
      grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(280px, 1fr))';
      btnGrid.classList.add('active');
      btnList.classList.remove('active');
    }
  }

  async toggleFavorite(itemId) {
    try {
      const res = await fetch(`${this.apiBase}/items/${itemId}/favorite`, {
        method: 'POST',
        headers: this.getHeaders()
      });
      const data = await res.json();
      if (data.success) {
        this.showToast(data.data.isFavorite ? 'Item adicionado aos favoritos!' : 'Item removido dos favoritos.');
      }
    } catch (err) {
      this.showToast('Erro ao atualizar favorito: ' + err.message, 'error');
    }
  }

  // ==========================================
  // DETALHES DO ITEM (M-02)
  // ==========================================
  openDetailModal(itemId) {
    const item = this.items.find(i => i.id === itemId);
    if (!item) return;

    this.selectedItem = item;
    const imgUrl = item.images && item.images.length > 0 ? item.images[0] : '';
    document.getElementById('detailMainImg').src = imgUrl;
    document.getElementById('detailCategory').textContent = item.category;
    document.getElementById('detailTitle').textContent = item.full_title || item.title;
    document.getElementById('detailLocation').innerHTML = `<i class="fa-solid fa-location-dot"></i> ${item.neighborhood || 'Pinheiros, SP'} • ${item.distance_label || ''}`;
    document.getElementById('detailDailyPrice').textContent = `R$ ${item.daily_price.toFixed(2).replace('.', ',')}`;
    document.getElementById('detailDesc').textContent = item.description;

    document.getElementById('detailHostName').textContent = item.owner_name || 'Lucas Mendes';
    document.getElementById('detailHostAvatar').src = item.owner_avatar || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80';
    document.getElementById('detailHostRating').innerHTML = `<i class="fa-solid fa-star star-icon"></i> ${item.owner_rating ? item.owner_rating.toFixed(1) : '5.0'} (${item.owner_reviews_count || 12} avaliações) • ${item.owner_since || 'Desde 2024'}`;

    this.recalculateDetailPricing();
    this.openModal('detailModal');
  }

  recalculateDetailPricing() {
    if (!this.selectedItem) return;

    const startDate = new Date(document.getElementById('rentalStartDate').value);
    const endDate = new Date(document.getElementById('rentalEndDate').value);

    let days = Math.ceil(Math.abs(endDate - startDate) / (1000 * 60 * 60 * 24));
    if (isNaN(days) || days < 1) days = 1;

    const daily = this.selectedItem.daily_price;
    const subtotal = daily * days;
    const discount = days >= 3 ? subtotal * 0.15 : 0.0;
    const base = subtotal - discount;
    const serviceFee = Number((base * 0.10).toFixed(2));
    const total = Number((base + serviceFee).toFixed(2));
    const deposit = this.selectedItem.deposit_amount;

    this.calculatedRentalPricing = {
      days,
      daily,
      subtotal,
      discount,
      serviceFee,
      total,
      deposit,
      startDate: document.getElementById('rentalStartDate').value,
      endDate: document.getElementById('rentalEndDate').value
    };

    document.getElementById('calcDaysLabel').textContent = `Diárias (${days} ${days > 1 ? 'dias' : 'dia'})`;
    document.getElementById('calcSubtotal').textContent = `R$ ${subtotal.toFixed(2).replace('.', ',')}`;

    const discountRow = document.getElementById('calcDiscountRow');
    if (discount > 0) {
      discountRow.style.display = 'flex';
      document.getElementById('calcDiscount').textContent = `- R$ ${discount.toFixed(2).replace('.', ',')}`;
    } else {
      discountRow.style.display = 'none';
    }

    document.getElementById('calcServiceFee').textContent = `R$ ${serviceFee.toFixed(2).replace('.', ',')}`;
    document.getElementById('calcTotalPrice').textContent = `R$ ${total.toFixed(2).replace('.', ',')}`;
    document.getElementById('calcDepositAmount').textContent = `R$ ${deposit.toFixed(2).replace('.', ',')}`;
  }

  // ==========================================
  // CHECKOUT (M-03)
  // ==========================================
  proceedToCheckout() {
    this.closeModal('detailModal');
    if (!this.selectedItem || !this.calculatedRentalPricing) return;

    const imgUrl = this.selectedItem.images && this.selectedItem.images.length > 0 ? this.selectedItem.images[0] : '';
    document.getElementById('checkoutItemImg').src = imgUrl;
    document.getElementById('checkoutItemTitle').textContent = this.selectedItem.title;
    document.getElementById('checkoutDates').textContent = `${this.calculatedRentalPricing.startDate} até ${this.calculatedRentalPricing.endDate} (${this.calculatedRentalPricing.days} dias)`;

    this.updateCheckoutTotals();
    this.openModal('checkoutModal');
  }

  selectFreight(type) {
    this.checkoutFreight = type;
    document.querySelectorAll('.freight-option').forEach(el => el.classList.remove('selected'));
    if (type === 'pickup') document.getElementById('freightPickup').classList.add('selected');
    if (type === 'hostDelivery') document.getElementById('freightHost').classList.add('selected');
    if (type === 'courier') document.getElementById('freightCourier').classList.add('selected');

    this.updateCheckoutTotals();
  }

  setPaymentMethod(method) {
    this.checkoutPaymentMethod = method;
    const btnCard = document.getElementById('payMethodCard');
    const btnPix = document.getElementById('payMethodPix');
    const boxCard = document.getElementById('cardPaymentBox');
    const boxPix = document.getElementById('pixPaymentBox');

    if (method === 'creditCard') {
      btnCard.style.borderColor = 'var(--color-primary)';
      btnCard.style.color = 'var(--color-primary)';
      btnPix.style.borderColor = 'var(--color-outline-variant)';
      btnPix.style.color = 'inherit';
      boxCard.style.display = 'block';
      boxPix.style.display = 'none';
    } else {
      btnPix.style.borderColor = 'var(--color-primary)';
      btnPix.style.color = 'var(--color-primary)';
      btnCard.style.borderColor = 'var(--color-outline-variant)';
      btnCard.style.color = 'inherit';
      boxCard.style.display = 'none';
      boxPix.style.display = 'block';
    }
  }

  updateCheckoutTotals() {
    if (!this.calculatedRentalPricing) return;

    let freightCost = 0.0;
    if (this.checkoutFreight === 'hostDelivery') freightCost = 25.0;
    if (this.checkoutFreight === 'courier') freightCost = 35.0;

    const finalTotal = this.calculatedRentalPricing.total + freightCost;

    document.getElementById('checkoutTotalValue').textContent = `R$ ${finalTotal.toFixed(2).replace('.', ',')}`;
    document.getElementById('checkoutDepositValue').textContent = `R$ ${this.calculatedRentalPricing.deposit.toFixed(2).replace('.', ',')}`;
  }

  async executePayment() {
    const btn = document.getElementById('btnConfirmPay');
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Processando Custódia Escrow...';
    btn.disabled = true;

    try {
      const payload = {
        itemId: this.selectedItem.id,
        startDate: this.calculatedRentalPricing.startDate,
        endDate: this.calculatedRentalPricing.endDate,
        freightType: this.checkoutFreight,
        paymentMethod: this.checkoutPaymentMethod
      };

      const res = await fetch(`${this.apiBase}/rentals`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify(payload)
      });

      const data = await res.json();
      if (!data.success) {
        throw new Error(data.error?.message || 'Falha ao processar pagamento');
      }

      this.showToast('🎉 Pagamento aprovado! Reserva gerada com sucesso.');
      this.closeModal('checkoutModal');

      // Abre diretamente a gestão de entrega / chat
      this.openChatModal(data.data.rental.id);
    } catch (err) {
      this.showToast('Erro: ' + err.message, 'error');
    } finally {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }

  // ==========================================
  // CHAT & GESTÃO DA ENTREGA COM PIN (M-04)
  // ==========================================
  async openChatModal(rentalId) {
    try {
      const res = await fetch(`${this.apiBase}/rentals/${rentalId}`, { headers: this.getHeaders() });
      const data = await res.json();

      if (!data.success || !data.data?.rental) {
        throw new Error('Reserva não encontrada');
      }

      this.activeRental = data.data.rental;
      const r = this.activeRental;

      const imgUrl = r.item_images && r.item_images.length > 0 ? r.item_images[0] : '';
      document.getElementById('chatItemThumb').src = imgUrl;
      document.getElementById('chatItemTitle').textContent = r.item_title;
      document.getElementById('chatReservationCode').textContent = `Reserva #${r.id} • ${r.start_date} a ${r.end_date}`;

      // PIN Banner
      document.getElementById('chatPinDisplay').textContent = r.delivery_pin || '------';

      // Status Pill
      const pill = document.getElementById('chatStatusPill');
      pill.className = `chat-status-pill status-${r.rental_status}`;
      if (r.rental_status === 'paidConfirmed') pill.textContent = 'PAGO & CONFIRMADO';
      if (r.rental_status === 'inProgress') pill.textContent = 'EM CURSO';
      if (r.rental_status === 'completed') pill.textContent = 'FINALIZADO';

      await this.loadChatMessages();
      this.openModal('chatModal');

      // Inicia polling leve de novas mensagens no chat
      clearInterval(this.chatInterval);
      this.chatInterval = setInterval(() => this.loadChatMessages(true), 3000);
    } catch (err) {
      this.showToast('Erro ao abrir chat: ' + err.message, 'error');
    }
  }

  async loadChatMessages(isBackground = false) {
    if (!this.activeRental) return;

    try {
      const res = await fetch(`${this.apiBase}/chat/${this.activeRental.id}`, { headers: this.getHeaders() });
      const data = await res.json();

      if (data.success) {
        const messages = data.data.messages || [];
        const container = document.getElementById('chatMessagesArea');
        container.innerHTML = messages.map(m => {
          let extra = '';
          if (m.photo_urls && m.photo_urls.length > 0) {
            extra = `<img src="${m.photo_urls[0]}" style="max-width: 100%; border-radius: 8px; margin-top: 8px;">`;
          }
          return `
            <div class="message-bubble ${m.sender_type}">
              <strong>${m.sender_name}</strong>
              <p>${m.message}</p>
              ${extra}
              <div class="message-meta">${new Date(m.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</div>
            </div>
          `;
        }).join('');

        if (!isBackground) {
          container.scrollTop = container.scrollHeight;
        }
      }
    } catch (err) {
      console.warn('Erro ao carregar mensagens:', err);
    }
  }

  async sendChatMessage() {
    const input = document.getElementById('chatInputMessage');
    const text = input.value.trim();
    if (!text || !this.activeRental) return;

    input.value = '';
    try {
      const res = await fetch(`${this.apiBase}/chat/${this.activeRental.id}`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ text })
      });
      const data = await res.json();
      if (data.success) {
        await this.loadChatMessages();
      }
    } catch (err) {
      this.showToast('Erro ao enviar mensagem: ' + err.message, 'error');
    }
  }

  promptVerifyPin() {
    if (!this.activeRental) return;
    const pin = prompt(`Digite o código PIN de entrega de 6 dígitos para confirmar o recebimento do equipamento:\n(Dica Demo: o PIN gerado para esta reserva é ${this.activeRental.delivery_pin})`);
    if (!pin) return;

    this.verifyDeliveryPin(pin);
  }

  async verifyDeliveryPin(pin) {
    try {
      const res = await fetch(`${this.apiBase}/rentals/${this.activeRental.id}/verify-pin`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ pin })
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.error?.message || 'PIN incorreto');

      this.showToast('✅ PIN confirmado! Equipamento entregue e locação em curso.');
      this.openChatModal(this.activeRental.id);
    } catch (err) {
      this.showToast('Erro: ' + err.message, 'error');
    }
  }

  promptCompleteRental() {
    if (!this.activeRental) return;
    const confirmReturn = confirm('Deseja confirmar a devolução do equipamento em perfeitas condições e liberar o estorno da caução?');
    if (!confirmReturn) return;

    this.completeRental();
  }

  async completeRental() {
    try {
      const res = await fetch(`${this.apiBase}/rentals/${this.activeRental.id}/complete`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({})
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.error?.message || 'Falha ao concluir');

      this.showToast('🎉 Aluguel finalizado e caução devolvida com sucesso!');
      this.openChatModal(this.activeRental.id);
    } catch (err) {
      this.showToast('Erro: ' + err.message, 'error');
    }
  }

  promptAddInspection() {
    if (!this.activeRental) return;
    const title = prompt('Título da Foto de Vistoria (ex: Corpo do Equipamento, Lente Limpa, Teste Ligado):', 'Vistoria Pré-Entrega Conforme');
    if (!title) return;

    const photoUrl = 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=400&q=80';
    this.addInspection(title, photoUrl);
  }

  async addInspection(title, photoUrl) {
    try {
      const res = await fetch(`${this.apiBase}/chat/${this.activeRental.id}/inspection`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ title, photoUrl, step: 'pre_delivery' })
      });
      const data = await res.json();
      if (data.success) {
        this.showToast('📸 Foto de vistoria registrada com sucesso!');
        await this.loadChatMessages();
      }
    } catch (err) {
      this.showToast('Erro ao adicionar foto: ' + err.message, 'error');
    }
  }

  // ==========================================
  // MEUS ALUGUÉIS (M-05)
  // ==========================================
  async loadRentals() {
    try {
      const res = await fetch(`${this.apiBase}/rentals`, { headers: this.getHeaders() });
      const data = await res.json();

      if (data.success) {
        const rentals = data.data.rentals || [];
        const container = document.getElementById('rentalsList');

        if (rentals.length === 0) {
          container.innerHTML = `
            <div style="text-align: center; padding: 40px; background: white; border-radius: 16px; border: 1px dashed var(--color-outline);">
              <i class="fa-solid fa-clock-rotate-left" style="font-size: 2.5rem; color: var(--color-outline); margin-bottom: 8px;"></i>
              <h3 style="font-weight: 700;">Nenhum aluguel encontrado</h3>
              <p style="color: var(--color-on-surface-variant); font-size: 0.9rem;">Explore o catálogo e alugue seu primeiro equipamento!</p>
            </div>
          `;
          return;
        }

        container.innerHTML = rentals.map(r => {
          const imgUrl = r.item_images && r.item_images.length > 0 ? r.item_images[0] : '';
          let statusText = 'PAGO & CONFIRMADO';
          if (r.rental_status === 'inProgress') statusText = 'EM CURSO';
          if (r.rental_status === 'completed') statusText = 'FINALIZADO';

          return `
            <div style="background: white; border-radius: var(--radius-lg); border: 1px solid var(--color-outline-variant); padding: 18px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: var(--shadow-sm); flex-wrap: wrap;">
              <div style="display: flex; align-items: center; gap: 16px;">
                <img src="${imgUrl}" style="width: 72px; height: 72px; border-radius: var(--radius-md); object-fit: cover;">
                <div>
                  <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                    <span class="chat-status-pill status-${r.rental_status}">${statusText}</span>
                    <span style="font-size: 0.75rem; color: var(--color-on-surface-variant);">PIN: <strong>${r.delivery_pin}</strong></span>
                  </div>
                  <h3 style="font-size: 1.05rem; font-weight: 700;">${r.item_title}</h3>
                  <p style="font-size: 0.8rem; color: var(--color-on-surface-variant);">
                    <i class="fa-regular fa-calendar"></i> ${r.start_date} até ${r.end_date} (${r.days_count} dias) • Total R$ ${r.total_price.toFixed(2).replace('.', ',')}
                  </p>
                </div>
              </div>
              <button class="btn-primary" onclick="app.openChatModal('${r.id}')">
                <i class="fa-solid fa-comments"></i> Abrir Chat & Entrega
              </button>
            </div>
          `;
        }).join('');
      }
    } catch (err) {
      this.showToast('Erro ao carregar reservas: ' + err.message, 'error');
    }
  }

  // ==========================================
  // ANUNCIAR NOVO ITEM (M-06)
  // ==========================================
  openPostItemModal() {
    this.openModal('postItemModal');
  }

  async submitPostItem() {
    const title = document.getElementById('postTitle').value.trim();
    const category = document.getElementById('postCategory').value;
    const neighborhood = document.getElementById('postNeighborhood').value.trim();
    const dailyPrice = document.getElementById('postDailyPrice').value;
    const depositAmount = document.getElementById('postDepositAmount').value;
    const imageUrl = document.getElementById('postImageUrl').value.trim();
    const description = document.getElementById('postDescription').value.trim();

    try {
      const payload = {
        title,
        category,
        neighborhood,
        daily_price: dailyPrice,
        deposit_amount: depositAmount,
        images: imageUrl ? [imageUrl] : [],
        description
      };

      const res = await fetch(`${this.apiBase}/items`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify(payload)
      });

      const data = await res.json();
      if (!data.success) throw new Error(data.error?.message || 'Falha ao cadastrar anúncio');

      this.showToast('🎉 Anúncio publicado com sucesso no catálogo!');
      this.closeModal('postItemModal');
      document.getElementById('postItemForm').reset();
      await this.loadItems();
    } catch (err) {
      this.showToast('Erro: ' + err.message, 'error');
    }
  }

  // ==========================================
  // VALIDAÇÃO KYC (M-07)
  // ==========================================
  openKycModal() {
    this.openModal('kycModal');
  }

  async submitKyc() {
    const documentType = document.getElementById('kycDocType').value;
    const documentNumber = document.getElementById('kycDocNumber').value.trim();

    try {
      const res = await fetch(`${this.apiBase}/auth/kyc`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ documentType, documentNumber })
      });

      const data = await res.json();
      if (!data.success) throw new Error(data.error?.message || 'Falha na validação');

      this.showToast('✅ Documento validado com sucesso! KYC Aprovado.');
      this.closeModal('kycModal');
      await this.loadUserProfile();
    } catch (err) {
      this.showToast('Erro: ' + err.message, 'error');
    }
  }

  // ==========================================
  // NAVEGAÇÃO & UI
  // ==========================================
  showSection(section) {
    document.getElementById('sectionExplore').style.display = section === 'explore' ? 'block' : 'none';
    document.getElementById('filterBar').style.display = section === 'explore' ? 'block' : 'none';
    document.getElementById('sectionRentals').style.display = section === 'rentals' ? 'block' : 'none';
    document.getElementById('sectionProfile').style.display = section === 'profile' ? 'block' : 'none';

    document.querySelectorAll('.nav-link-btn').forEach(btn => btn.classList.remove('active'));
    if (section === 'explore') document.getElementById('navExplore')?.classList.add('active');
    if (section === 'rentals') {
      document.getElementById('navRentals')?.classList.add('active');
      this.loadRentals();
    }
  }

  openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.add('active');
  }

  closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.remove('active');
    if (modalId === 'chatModal') {
      clearInterval(this.chatInterval);
      this.activeRental = null;
    }
  }

  showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    const icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
    toast.innerHTML = `<i class="fa-solid ${icon}"></i> <span>${message}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      setTimeout(() => toast.remove(), 300);
    }, 3500);
  }
}

// Inicializa a aplicação
window.app = new AlugaTudoApp();

