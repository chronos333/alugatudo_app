import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'network_image_fallback.dart';

class PinModalBottomSheet extends StatelessWidget {
  final String pinCode;

  const PinModalBottomSheet({super.key, this.pinCode = '849 • 210'});

  static Future<void> show(BuildContext context, {String pinCode = '849 • 210'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PinModalBottomSheet(pinCode: pinCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Código de Retirada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: AppTheme.outline),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Apresente este código ou o QR code para Lucas escanear e confirmar a entrega das chaves/equipamento.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.35,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // PIN Display Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                pinCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // QR Code Box
            Container(
              width: 160,
              height: 160,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: NetworkImageFallback(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDJ-Cy0HmSF4KcocRIa7oSDUxgKcrOrYJLuf86SsjPLntQjWEVkMmnUJtKp2n2gpS1W4ddCzirJo8T2mwYAfJOqlO2ZezzG8VJnyJaWKnL8BPz2F6bkOzeTwK3Lsmz2G5Z8HnUL6sXN30ti_QIryQEM-oket2_6O9Dscoor7Kw8AtcPWN4QqajH-MYJpUEm_J6M8BHpRreB4lMeawq8Imv1_NFkV3ww_R7RJhKNkz0X',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Guarantee Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 16, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Liberação de pagamento vinculada à validação física.',
                      style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
