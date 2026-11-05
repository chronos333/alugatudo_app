import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/item_model.dart';
import '../models/rental_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/kyc_modal.dart';
import '../widgets/network_image_fallback.dart';
import '../widgets/trust_badges.dart';
import 'checkout_view.dart';
import 'chat_view.dart';

class ItemDetailView extends StatefulWidget {
  final ItemModel item;

  const ItemDetailView({super.key, required this.item});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  int _activeCarouselPage = 0;
  final PageController _pageController = PageController();

  DateTime _startDate = DateTime(2026, 10, 18, 9, 0);
  DateTime _endDate = DateTime(2026, 10, 20, 19, 0);

  FreightType _selectedFreight = FreightType.pickup;

  final currencyFormatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  int get _calculatedDays {
    final diff = _endDate.difference(_startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  double get _subtotal => _calculatedDays * widget.item.dailyPrice;
  double get _discount => _calculatedDays >= 3 ? (_subtotal * 0.15) : 0.0;
  double get _platformFee => _subtotal * 0.10;
  double get _freightCost => _selectedFreight.cost;
  double get _totalPrice => _subtotal - _discount + _platformFee + _freightCost;

  void _pickDates() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryContainer,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceContainerLowest,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (pickedRange != null) {
      final messenger = ScaffoldMessenger.of(context);
      final controller = context.read<AlugaController>();
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
      controller.updateDates(_startDate, _endDate);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Período atualizado: $_calculatedDays diárias selecionadas!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleBookingRequest(BuildContext context) {
    final controller = context.read<AlugaController>();

    if (!controller.isKycApproved) {
      KycModalBottomSheet.show(
        context,
        onComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Identidade verificada com sucesso! Você já pode alugar.',
              ),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _navigateToCheckout(context);
        },
      );
    } else {
      _navigateToCheckout(context);
    }
  }

  void _navigateToCheckout(BuildContext context) {
    final controller = context.read<AlugaController>();
    controller.updateFreightType(_selectedFreight);
    controller.updateDates(_startDate, _endDate);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutView(
          item: widget.item,
          startDate: _startDate,
          endDate: _endDate,
          freightType: _selectedFreight,
          daysCount: _calculatedDays,
          subtotal: _subtotal,
          discount: _discount,
          platformFee: _platformFee,
          freightCost: _freightCost,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final isFavorite = widget.item.isFavorite;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Detalhe Do Anúncio',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Visual Carousel with Dots
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.elevatedShadow,
                color: AppTheme.surfaceContainerLowest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    children: [
                      // PageView
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.item.images.length,
                        onPageChanged: (idx) {
                          setState(() => _activeCarouselPage = idx);
                        },
                        itemBuilder: (context, idx) {
                          return NetworkImageFallback(
                            imageUrl: widget.item.images[idx],
                            fit: BoxFit.cover,
                          );
                        },
                      ),

                      // Top-Left Caução Garantida
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: EscrowBadge(),
                      ),

                      // Top-Right Favorite button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            controller.toggleFavorite(widget.item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !isFavorite
                                      ? 'Item salvo nos favoritos!'
                                      : 'Removido dos favoritos',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: isFavorite
                                  ? AppTheme.error
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      // Carousel Dots Pagination
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.item.images.length,
                            (idx) {
                              final isActive = _activeCarouselPage == idx;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.primaryContainer
                                      : AppTheme.surfaceContainerLowest
                                          .withValues(alpha: 0.7),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusFull),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 2. Tags & Location Meta
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    widget.item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item.distanceLabel} (${widget.item.neighborhood})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceSm),

            // 3. Title & Headline
            Text(
              widget.item.fullTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 4. Pricing with Micro-offer Tag
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'R\$ ${widget.item.dailyPrice.toInt()} ',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: AppTheme.onSurface,
                              ),
                        ),
                        TextSpan(
                          text: '/ dia',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer_rounded,
                            size: 14, color: AppTheme.onSecondaryContainer),
                        SizedBox(width: 4),
                        Text(
                          '15% OFF para 3+ dias',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 5. Host Profile Card
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
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipOval(
                            child: NetworkImageFallback(
                              imageUrl: widget.item.ownerAvatarUrl,
                              width: 52,
                              height: 52,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.item.ownerFullName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const KycBadge(text: 'KYC Aprovado'),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14, color: AppTheme.starAmber),
                                const SizedBox(width: 2),
                                Text(
                                  '★ ${widget.item.ownerRating.toStringAsFixed(1)} ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '(${widget.item.ownerReviewsCount} aluguéis) • ${widget.item.ownerSince}',
                                  style: const TextStyle(
                                    fontSize: 12,
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
                  const SizedBox(height: AppTheme.spaceMd),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatView(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainer,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: AppTheme.onSurface),
                      label: Text(
                        'Conversar com ${widget.item.ownerName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 6. Security Deposit / Caução Info Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 22,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Garantia por Caução',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                currencyFormatter.format(widget.item.depositAmount),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Valor bloqueado temporariamente no cartão e liberado integralmente após a devolução sem avarias. 100% protegido pela custódia AlugaTudo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 7. Period & Date Range Selector
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
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 20, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          const Text(
                            'Período do Aluguel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          '$_calculatedDays diárias selecionadas',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // Dates buttons
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDates,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RETIRADA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEE, d MMM', 'pt_BR')
                                      .format(_startDate),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'A partir das 09:00',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: _pickDates,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DEVOLUÇÃO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEE, d MMM', 'pt_BR')
                                      .format(_endDate),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Até às 19:00',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Disponibilidade imediata',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDates,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Alterar datas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 8. Logistics & Delivery Options
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
                  const Row(
                    children: [
                      Icon(Icons.local_shipping_rounded,
                          size: 20, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Text(
                        'Como deseja retirar o equipamento?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  ...FreightType.values.map((fType) {
                    final isChecked = _selectedFreight == fType;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFreight = fType),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppTheme.surfaceContainerHigh.withValues(alpha: 0.8)
                                : AppTheme.surfaceContainerLow,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: isChecked
                                  ? AppTheme.primaryContainer
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isChecked
                                        ? AppTheme.primaryContainer
                                        : AppTheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: isChecked
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
                                    Text(
                                      fType.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      fType.subtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (fType.cost == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Grátis',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSecondaryContainer,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  fType.costLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 9. Transparent Financial Breakdown
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
                    'Resumo Transparente de Valores',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diárias ($_calculatedDays x ${currencyFormatter.format(widget.item.dailyPrice)})',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.onSurfaceVariant),
                      ),
                      Text(
                        currencyFormatter.format(_subtotal),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (_discount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.redeem_rounded,
                                size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Desconto fidelidade (15%)',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.primary),
                            ),
                          ],
                        ),
                        Text(
                          '- ${currencyFormatter.format(_discount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taxa de proteção & plataforma (10%)',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.onSurfaceVariant),
                      ),
                      Text(
                        currencyFormatter.format(_platformFee),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Frete / Logística',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.onSurfaceVariant),
                      ),
                      Text(
                        _selectedFreight.costLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedFreight.cost == 0
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceSm),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total a Pagar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Caução de ${currencyFormatter.format(widget.item.depositAmount)} apenas autorizada',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.outline,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormatter.format(_totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // 10. KYC Simulation Sandbox Box (Gherkin Requirement from Stitch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          size: 18, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Text(
                        'Simular status do usuário:',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: controller.toggleKycSimulation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Text('Status: ', style: TextStyle(fontSize: 11)),
                          Text(
                            controller.isKycApproved ? 'APROVADO' : 'PENDENTE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: controller.isKycApproved
                                  ? AppTheme.primaryContainer
                                  : AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // spacing for sticky bottom bar
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.98),
          boxShadow: AppTheme.bottomNavShadow,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: 12,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Valor Total',
                    style: TextStyle(fontSize: 11, color: AppTheme.outline),
                  ),
                  Text(
                    currencyFormatter.format(_totalPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    '$_calculatedDays diárias',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBookingRequest(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: Text(
                      'Solicitar Aluguel • ${currencyFormatter.format(_totalPrice)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
