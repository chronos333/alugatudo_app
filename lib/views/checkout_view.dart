import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/item_model.dart';
import '../models/rental_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/network_image_fallback.dart';
import 'chat_view.dart';

class CheckoutView extends StatefulWidget {
  final ItemModel item;
  final DateTime startDate;
  final DateTime endDate;
  final FreightType freightType;
  final int daysCount;
  final double subtotal;
  final double discount;
  final double platformFee;
  final double freightCost;
  final double totalPrice;

  const CheckoutView({
    super.key,
    required this.item,
    required this.startDate,
    required this.endDate,
    required this.freightType,
    required this.daysCount,
    required this.subtotal,
    required this.discount,
    required this.platformFee,
    required this.freightCost,
    required this.totalPrice,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  PaymentMethodType _paymentMethod = PaymentMethodType.creditCard;
  bool _termsAgreed = true;
  String _installments = '1x R\$ 429,00 (sem juros)';
  final TextEditingController _cvvController =
      TextEditingController(text: '345');

  final currencyFormatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  RentalStatus _bookingState = RentalStatus.requested;
  bool _isProcessing = false;

  void _confirmCheckout() async {
    if (!_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, aceite os termos e o compromisso de vistoria fotográfica.',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await context.read<AlugaController>().processCheckout();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _bookingState = RentalStatus.paidConfirmed;
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Caução reservada! Redirecionando para chat do anfitrião...',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // Transition to Screen 4 (M-04: Chat & Gestão da Reserva)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ChatView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Checkout Do Aluguel',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Flow Indicator: Etapa 2 de 2 • SSL 256-Bit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ETAPA 2 DE 2 • FINALIZAÇÃO SEGURA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 13, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text(
                        'SSL 256-Bit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Item Summary Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: NetworkImageFallback(
                          imageUrl: widget.item.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'P2P',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 14, color: AppTheme.primaryContainer),
                            SizedBox(width: 4),
                            Text(
                              'Anúncio Verificado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 13, color: AppTheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('d MMM', 'pt_BR').format(widget.startDate)} - ${DateFormat('d MMM', 'pt_BR').format(widget.endDate)} (${widget.daysCount} diárias)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions_walk_rounded,
                                      size: 11, color: AppTheme.onSurface),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.freightType.title,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '★ ${widget.item.ownerRating} (${widget.item.ownerReviewsCount})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Financial Breakdown Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detalhamento dos Custos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: const Text(
                          'Transparência 100%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal Aluguel (${widget.daysCount} diárias × ${currencyFormatter.format(widget.item.dailyPrice)})',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.onSurfaceVariant),
                      ),
                      Text(
                        currencyFormatter.format(widget.subtotal),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Taxa de Frete / Entrega',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.freightType.title})',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.freightCost == 0
                            ? 'R\$ 0,00'
                            : currencyFormatter.format(widget.freightCost),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Taxa de Serviço da Plataforma (10%)',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.onSurfaceVariant),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.help_outline_rounded,
                              size: 14, color: AppTheme.outline),
                        ],
                      ),
                      Text(
                        currencyFormatter.format(widget.platformFee),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceSm),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total a Pagar Agora',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Cobrança instantânea',
                              style: TextStyle(
                                  fontSize: 10, color: AppTheme.outline),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormatter.format(widget.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            const Text(
                              'em até 3x sem juros',
                              style: TextStyle(
                                  fontSize: 10, color: AppTheme.outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Financial Security & Escrow Guarantee Box
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Proteção por Caução Garantida',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(widget.item.depositAmount),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '• Apenas bloqueio temporário • Não entra na fatura',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Limite reservado temporariamente no cartão de crédito. Não é cobrado em fatura e é liberado em até 2 horas após a vistoria de devolução confirmada por ambas as partes.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Payment Methods Selector
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Forma de Pagamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // Option 1: Credit Card
                  InkWell(
                    onTap: () {
                      setState(() {
                        _paymentMethod = PaymentMethodType.creditCard;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == PaymentMethodType.creditCard
                            ? AppTheme.surfaceContainer
                            : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: _paymentMethod == PaymentMethodType.creditCard
                              ? AppTheme.primaryContainer
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _paymentMethod == PaymentMethodType.creditCard
                                    ? AppTheme.primaryContainer
                                    : AppTheme.outline,
                                width: 2,
                              ),
                            ),
                            child: _paymentMethod == PaymentMethodType.creditCard
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.credit_card_rounded,
                                            size: 16, color: AppTheme.primary),
                                        SizedBox(width: 4),
                                        Text(
                                          'Cartão de Crédito',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: const Text(
                                        'Recomendado',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Cartão final 4092 • Visa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Pré-autorização instantânea da caução sem desembolso',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Inline Card details (CVV + Installments)
                  if (_paymentMethod == PaymentMethodType.creditCard) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Código de Segurança (CVV)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _cvvController,
                                maxLength: 4,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  suffixIcon: Icon(Icons.help_outline_rounded,
                                      size: 16, color: AppTheme.outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Parcelamento',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _installments,
                                items: const [
                                  DropdownMenuItem(
                                    value: '1x R\$ 429,00 (sem juros)',
                                    child: Text('1x R\$ 429,00 (sem juros)',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: '2x R\$ 214,50 (sem juros)',
                                    child: Text('2x R\$ 214,50 (sem juros)',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: '3x R\$ 143,00 (sem juros)',
                                    child: Text('3x R\$ 143,00 (sem juros)',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _installments = val);
                                  }
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Option 2: PIX Instantâneo
                  InkWell(
                    onTap: () {
                      setState(() {
                        _paymentMethod = PaymentMethodType.pix;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == PaymentMethodType.pix
                            ? AppTheme.surfaceContainer
                            : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: _paymentMethod == PaymentMethodType.pix
                              ? AppTheme.primaryContainer
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _paymentMethod == PaymentMethodType.pix
                                    ? AppTheme.primaryContainer
                                    : AppTheme.outline,
                                width: 2,
                              ),
                            ),
                            child: _paymentMethod == PaymentMethodType.pix
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.qr_code_2_rounded,
                                            size: 16, color: AppTheme.outline),
                                        SizedBox(width: 4),
                                        Text(
                                          'PIX Instantâneo',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerHigh,
                                        borderRadius:
                                            BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: const Text(
                                        'Conta Custódia',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Caução retida em conta escrow certificada',
                                  style: TextStyle(fontSize: 11),
                                ),
                                const Text(
                                  'Devolução automática via Pix em minutos após inspeção',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Terms of Service & Photo Inspection Agreement
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAgreed,
                        activeColor: AppTheme.primaryContainer,
                        onChanged: (val) {
                          setState(() => _termsAgreed = val ?? false);
                        },
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _termsAgreed = !_termsAgreed);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.onSurface,
                                    height: 1.3),
                                children: [
                                  TextSpan(text: 'Concordo com os '),
                                  TextSpan(
                                    text: 'Termos de Locação P2P',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' e com a obrigatoriedade da ',
                                  ),
                                  TextSpan(
                                    text: 'Inspeção Fotográfica',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' realizada na entrega e devolução.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_camera_rounded,
                                size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Check-in com 4 fotos',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Cobertura antifraude',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Primary Action Button Sticky/Bottom
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bookingState == RentalStatus.paidConfirmed
                      ? AppTheme.primaryContainer
                      : AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 2,
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, size: 20),
                label: Text(
                  _isProcessing
                      ? 'Processando caução segura...'
                      : _bookingState == RentalStatus.paidConfirmed
                          ? 'Reserva Confirmada com Sucesso!'
                          : _paymentMethod == PaymentMethodType.creditCard
                              ? 'Confirmar Reserva e Bloqueio (${currencyFormatter.format(widget.totalPrice)})'
                              : 'Pagar ${currencyFormatter.format(widget.totalPrice)} via PIX Garantido',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Status da Reserva Pill Indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security_rounded,
                      size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  const Text(
                    'Status da Reserva: ',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _bookingState == RentalStatus.paidConfirmed
                          ? AppTheme.primaryContainer
                          : AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _bookingState.codeTag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _bookingState == RentalStatus.paidConfirmed
                            ? Colors.white
                            : AppTheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
