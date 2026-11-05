import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import 'network_image_fallback.dart';
import 'trust_badges.dart';

class ListingCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Container: 4:3 Aspect Ratio
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLg),
                    ),
                    child: NetworkImageFallback(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Top-Left: Caução Garantida
                  if (item.hasEscrowGuarantee)
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: EscrowBadge(),
                    ),

                  // Top-Right: Favorite Wishlist Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest
                              .withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Icon(
                          item.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: item.isFavorite
                              ? AppTheme.error
                              : AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Left: Distance Tag
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: DistanceBadge(label: item.distanceLabel),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppTheme.spaceSm),

                      // Price & Deposit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: currencyFormatter.format(item.dailyPrice),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                ),
                                TextSpan(
                                  text: '/dia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Caução: ${currencyFormatter.format(item.depositAmount)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spaceMd),

                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFFF1F5F9),
                  ),

                  const SizedBox(height: AppTheme.spaceSm),

                  // Host Info & KYC Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Host Avatar, Name & Rating
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  item.ownerName.substring(0, 1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.ownerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.starAmber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  item.ownerRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.starAmber,
                                  ),
                                ),
                                Text(
                                  ' (${item.ownerReviewsCount})',
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
                      const SizedBox(width: 6),

                      // Right Badge (KYC or Quick Pickup)
                      if (item.isQuickPickup)
                        const FeaturePill(
                          icon: Icons.bolt_rounded,
                          label: 'Retirada rápida',
                        )
                      else if (item.isKycVerified)
                        const KycBadge(text: 'KYC Verificado')
                      else
                        const FeaturePill(
                          icon: Icons.event_available_rounded,
                          label: 'Fim de semana livre',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
