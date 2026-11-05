import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../theme/app_theme.dart';

class CategoryChipsBar extends StatelessWidget {
  const CategoryChipsBar({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ferramentas':
        return Icons.build_rounded;
      case 'Eletrônicos & Câmeras':
        return Icons.photo_camera_rounded;
      case 'Festas & Eventos':
        return Icons.celebration_rounded;
      case 'Esportes':
        return Icons.sports_soccer_rounded;
      case 'Moda':
        return Icons.checkroom_rounded;
      case 'Todas':
      default:
        return Icons.apps_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final selectedCategory = controller.selectedCategory;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginMobile,
        vertical: 4,
      ),
      child: Row(
        children: controller.categories.map((category) {
          final isSelected = selectedCategory == category;
          final icon = _getCategoryIcon(category);

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceSm),
            child: InkWell(
              onTap: () => controller.setSelectedCategory(category),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: isSelected ? AppTheme.cardShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? AppTheme.onPrimary
                          : AppTheme.primaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.onPrimary
                            : AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
