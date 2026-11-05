import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/kyc_modal.dart';
import '../widgets/network_image_fallback.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final user = controller.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceMd,
        ),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryContainer,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.surfaceContainerHigh,
                          child: ClipOval(
                            child: NetworkImageFallback(
                              imageUrl: user.avatarUrl,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                      ),
                      if (user.kycStatus.isApproved)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Aluguéis',
                        value: '${user.completedRentals}',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppTheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'Avaliação',
                        value: '★ ${user.rating.toStringAsFixed(1)}',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppTheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'Bairro',
                        value: user.neighborhood,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // KYC Status Tile
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: user.kycStatus.isApproved
                    ? AppTheme.secondaryContainer.withValues(alpha: 0.35)
                    : AppTheme.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: user.kycStatus.isApproved
                      ? AppTheme.primaryContainer
                      : AppTheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    user.kycStatus.isApproved
                        ? Icons.verified_user_rounded
                        : Icons.pending_actions_rounded,
                    color: user.kycStatus.isApproved
                        ? AppTheme.primary
                        : AppTheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identidade KYC: ${user.kycStatus.label}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: user.kycStatus.isApproved
                                ? AppTheme.primary
                                : AppTheme.error,
                          ),
                        ),
                        Text(
                          user.kycStatus.isApproved
                            ? 'Sua conta está 100% liberada para locações.'
                            : 'Envie um documento para desbloquear o aluguel seguro.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!user.kycStatus.isApproved) {
                        KycModalBottomSheet.show(context, onComplete: () {});
                      } else {
                        controller.toggleKycSimulation();
                      }
                    },
                    child: Text(
                      user.kycStatus.isApproved ? 'Alternar' : 'Verificar',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Settings Options List
            Card(
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              color: AppTheme.surfaceContainerLowest,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.credit_card_rounded,
                        color: AppTheme.primary),
                    title: const Text('Cartões & Pagamento',
                        style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Visa final 4092',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined,
                        color: AppTheme.primary),
                    title: const Text('Garantia de Caução & Escrow',
                        style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Custódia e mediação ativa',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.primary),
                    title: const Text('Segurança e Privacidade',
                        style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded,
                        color: AppTheme.primary),
                    title: const Text('Central de Ajuda & FAQ',
                        style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }
}
