import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../theme/app_theme.dart';

class KycModalBottomSheet extends StatefulWidget {
  final VoidCallback onVerificationComplete;

  const KycModalBottomSheet({super.key, required this.onVerificationComplete});

  static Future<void> show(BuildContext context, {required VoidCallback onComplete}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KycModalBottomSheet(onVerificationComplete: onComplete),
    );
  }

  @override
  State<KycModalBottomSheet> createState() => _KycModalBottomSheetState();
}

class _KycModalBottomSheetState extends State<KycModalBottomSheet> {
  bool _isUploading = false;

  Future<void> _handleUpload() async {
    setState(() => _isUploading = true);

    final controller = context.read<AlugaController>();
    await controller.submitKycVerification();

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pop(context);
      widget.onVerificationComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: AppTheme.spaceLg,
        right: AppTheme.spaceLg,
        top: AppTheme.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceLg,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pill
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Icon & Trust visual
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: const Icon(
                Icons.badge_rounded,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // Title & Description
            Text(
              'Verificação de Identidade Necessária',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Para sua segurança e da comunidade, confirme sua identidade enviando um documento antes de alugar este equipamento.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Benefits Checklist
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Column(
                children: [
                  _BenefitItem(
                    icon: Icons.verified_rounded,
                    text: 'Validação automatizada por inteligência artificial em 2 min',
                  ),
                  SizedBox(height: 10),
                  _BenefitItem(
                    icon: Icons.lock_rounded,
                    text: 'Seus dados e fotos são criptografados de ponta a ponta',
                  ),
                  SizedBox(height: 10),
                  _BenefitItem(
                    icon: Icons.shield_rounded,
                    text: 'Desbloqueio de caução segura para qualquer categoria',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 2,
                ),
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.document_scanner_rounded, size: 20),
                label: Text(
                  _isUploading
                      ? 'Processando validação IA...'
                      : 'Enviar Documentos Agora',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.surfaceContainer,
                  foregroundColor: AppTheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: const Text(
                  'Fazer isso mais tarde',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryContainer),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.onSurface,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
