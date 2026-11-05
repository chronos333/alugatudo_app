import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chips.dart';
import '../widgets/listing_card.dart';
import '../widgets/skeleton_loader.dart';
import 'item_detail_view.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  void _showFilterModal(BuildContext context, AlugaController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          'Filtros de Busca',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            controller.setSelectedCategory('Todas');
                            controller.setSelectedRadius(10.0);
                            controller.setSearchQuery('');
                            Navigator.pop(ctx);
                          },
                          child: const Text('Limpar filtros'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Text(
                      'Raio Máximo de Distância',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Row(
                      children: controller.radiusOptions.map((r) {
                        final isSel = controller.selectedRadiusKm == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${r.toInt()} km'),
                            selected: isSel,
                            selectedColor: AppTheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: isSel ? AppTheme.onPrimary : AppTheme.onSurface,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              if (val) {
                                controller.setSelectedRadius(r);
                                setModalState(() {});
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: const Text('Aplicar Filtros'),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final items = controller.filteredItems;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: AppTheme.primaryContainer,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input & Filter Button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppTheme.outline, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: controller.setSearchQuery,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Buscar ferramentas, câmeras, festas...',
                        hintStyle: TextStyle(
                            color: AppTheme.outline, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  if (controller.searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppTheme.outline),
                      onPressed: () => controller.setSearchQuery(''),
                    ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          size: 20, color: AppTheme.primary),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showFilterModal(context, controller),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceSm),

            // Distance & Radius Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Primary Selected Radius Chip
                  InkWell(
                    onTap: () => _showFilterModal(context, controller),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded,
                              size: 15, color: AppTheme.onPrimaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            'Raio: ${controller.selectedRadiusKm.toInt()} km',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.expand_more_rounded,
                              size: 14, color: AppTheme.onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Location Tag Chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place_rounded,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.user.neighborhood}, SP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Quick distance presets (2km, 10km)
                  ...[2.0, 10.0].map((r) {
                    final isSelected = controller.selectedRadiusKm == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text('${r.toInt()} km'),
                        backgroundColor: isSelected
                            ? AppTheme.primaryContainer
                            : AppTheme.surfaceContainerLow,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.onPrimaryContainer
                              : AppTheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => controller.setSelectedRadius(r),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Horizontal Categories Scroll
            const CategoryChipsBar(),

            const SizedBox(height: AppTheme.spaceMd),

            // Section Header: Results Count + View Switcher (List / Map)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Explorar perto',
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          '${items.length} itens',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // View Mode Switcher Pill (Lista / Mapa)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // List button
                      InkWell(
                        onTap: () => controller.setViewMode(ViewMode.list),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: controller.viewMode == ViewMode.list
                                ? AppTheme.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: controller.viewMode == ViewMode.list
                                ? AppTheme.cardShadow
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 15,
                                color: controller.viewMode == ViewMode.list
                                    ? AppTheme.primary
                                    : AppTheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lista',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: controller.viewMode == ViewMode.list
                                      ? AppTheme.primary
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Map button
                      InkWell(
                        onTap: () => controller.setViewMode(ViewMode.map),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: controller.viewMode == ViewMode.map
                                ? AppTheme.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: controller.viewMode == ViewMode.map
                                ? AppTheme.cardShadow
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 15,
                                color: controller.viewMode == ViewMode.map
                                    ? AppTheme.primary
                                    : AppTheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Mapa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: controller.viewMode == ViewMode.map
                                      ? AppTheme.primary
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Content Area: List View OR Map View
            if (controller.viewMode == ViewMode.map) ...[
              _buildInteractiveMapView(context, controller, items),
            ] else ...[
              // Listing Items
              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppTheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum item encontrado',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tente alterar os termos da busca ou aumentar o raio de distância.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
                    child: ListingCard(
                      item: item,
                      onTap: () {
                        controller.selectItem(item);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailView(item: item),
                          ),
                        );
                      },
                      onFavoriteToggle: () {
                        controller.toggleFavorite(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              item.isFavorite
                                  ? 'Item salvo nos favoritos!'
                                  : 'Removido dos favoritos',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],

            const SizedBox(height: AppTheme.spaceMd),

            // Interactive Skeleton Loader Sandbox (Gherkin / Stitch component)
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Simulação de Fluxo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: controller.toggleSkeletonPreview,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          controller.showSkeletonPreview
                              ? 'Ocultar Skeleton'
                              : 'Testar Skeleton Loader',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (controller.showSkeletonPreview) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    const SkeletonCard(),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 80), // bottom bar spacing
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveMapView(
    BuildContext context,
    AlugaController controller,
    List<ItemModel> items,
  ) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          // Simulated Map Grid Backdrop with streets
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: CustomPaint(
                painter: _MapCanvasPainter(),
              ),
            ),
          ),

          // Map Pins for items
          Positioned(
            top: 50,
            left: 70,
            child: _MapPin(
              label: 'R\$ 130',
              title: 'Sony A7 III',
              isSelected: true,
              onTap: () {
                if (items.isNotEmpty) {
                  controller.selectItem(items[0]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailView(item: items[0]),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            top: 140,
            right: 60,
            child: _MapPin(
              label: 'R\$ 45',
              title: 'Parafusadeira',
              onTap: () {
                if (items.length > 1) {
                  controller.selectItem(items[1]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailView(item: items[1]),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: 90,
            left: 120,
            child: _MapPin(
              label: 'R\$ 85',
              title: 'Projetor',
              onTap: () {
                if (items.length > 2) {
                  controller.selectItem(items[2]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailView(item: items[2]),
                    ),
                  );
                }
              },
            ),
          ),

          // User Current Position Pin (Pinheiros)
          Positioned(
            top: 170,
            left: 170,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.inverseSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Você está aqui',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Quick Card Overlay on Map
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Toque nos pins de preço no mapa para abrir o detalhe do anúncio.',
                      style: TextStyle(fontSize: 11, color: AppTheme.onSurface),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.setViewMode(ViewMode.list),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Voltar à lista'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapPin({
    required this.label,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: isSelected ? Colors.white : AppTheme.primaryContainer,
                width: 1.5,
              ),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.onSurface,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: _TrianglePainter(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceContainerLowest,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    // Simulated roads
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.35, size.width, size.height * 0.7);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.6, size.height);
    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.2);
    canvas.drawPath(path3, secondaryRoadPaint);

    // Park / Green zones
    final parkPaint = Paint()..color = const Color(0xFFD1FAE5).withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 90, 70),
        const Radius.circular(16),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
