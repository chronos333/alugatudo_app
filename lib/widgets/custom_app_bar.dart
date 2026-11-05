import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'network_image_fallback.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _showLocationDialog(BuildContext context, AlugaController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        final locations = [
          {'city': 'São Paulo, SP', 'neighborhood': 'Pinheiros'},
          {'city': 'São Paulo, SP', 'neighborhood': 'Vila Madalena'},
          {'city': 'São Paulo, SP', 'neighborhood': 'Jardins'},
          {'city': 'São Paulo, SP', 'neighborhood': 'Moema'},
          {'city': 'São Paulo, SP', 'neighborhood': 'Itaim Bibi'},
        ];

        return Material(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
          child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  'Selecione sua Localização',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Itens mais próximos serão priorizados nos resultados.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                ...locations.map((loc) {
                  final isSelected =
                      controller.user.neighborhood == loc['neighborhood'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: isSelected ? AppTheme.primaryContainer : AppTheme.outline,
                    ),
                    title: Text(
                      '${loc['city']} - ${loc['neighborhood']}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primaryContainer)
                        : null,
                    onTap: () {
                      controller.updateLocation(
                        loc['city']!,
                        loc['neighborhood']!,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Localização alterada para ${loc['neighborhood']}!',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        return Material(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
          child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notificações',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: const Text(
                        '2 novas',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryContainer,
                    child: const Icon(Icons.verified_user_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                  title: const Text(
                    'Reserva #1020 confirmada',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Lucas M. enviou as fotos de vistoria da Sony A7 III.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Text(
                    '14:23',
                    style: TextStyle(fontSize: 11, color: AppTheme.outline),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    child: const Icon(Icons.shield_outlined,
                        color: AppTheme.primaryContainer, size: 20),
                  ),
                  title: const Text(
                    'Caução Bloqueada com Sucesso',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'R\$ 1.500,00 reservados em conta garantia escrow.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Text(
                    '14:20',
                    style: TextStyle(fontSize: 11, color: AppTheme.outline),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final user = controller.user;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.95),
        boxShadow: AppTheme.topBarShadow,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Back button or Logo + Location
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.onSurface),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                    ],

                    // App Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        MockDataService.logoUrl,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.swap_horizontal_circle,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'AlugaTudo',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: AppTheme.spaceSm),

                    // Title or Location Picker
                    if (title != null) ...[
                      Flexible(
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      Flexible(
                        child: InkWell(
                          onTap: () => _showLocationDialog(context, controller),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'LOCALIZAÇÃO',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.onSurfaceVariant,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        '${user.city} - ${user.neighborhood}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.expand_more_rounded,
                                      size: 14,
                                      color: AppTheme.outline,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Right Section: Notifications + User Avatar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: AppTheme.onSurface, size: 24),
                        onPressed: () => _showNotificationsDialog(context),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.surfaceContainerLowest, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spaceXs),
                  GestureDetector(
                    onTap: () => controller.setTabIndex(4),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryContainer.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: AppTheme.surfaceContainerHigh,
                            child: ClipOval(
                              child: NetworkImageFallback(
                                imageUrl: user.avatarUrl,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        if (user.kycStatus.isApproved)
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
