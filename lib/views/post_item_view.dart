import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';

class PostItemView extends StatefulWidget {
  const PostItemView({super.key});

  @override
  State<PostItemView> createState() => _PostItemViewState();
}

class _PostItemViewState extends State<PostItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  String _selectedCategory = 'Ferramentas';

  bool _isSaving = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AlugaController>();
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final dailyPrice = double.tryParse(_priceController.text) ?? 50.0;
    final deposit = double.tryParse(_depositController.text) ?? 200.0;

    final newItem = ItemModel(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      fullTitle: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      dailyPrice: dailyPrice,
      depositAmount: deposit,
      distanceKm: 0.5,
      distanceLabel: '500 m de você',
      neighborhood: controller.user.neighborhood,
      images: [
        'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?auto=format&fit=crop&w=600&q=80',
      ],
      ownerName: 'Você',
      ownerFullName: controller.user.name,
      ownerAvatarUrl: controller.user.avatarUrl,
      ownerRating: 5.0,
      ownerReviewsCount: 1,
      ownerSince: 'Desde 2026',
      pickupLocation: '${controller.user.neighborhood}, SP',
      tags: [_selectedCategory, 'Recente'],
    );

    controller.createNewListing(newItem);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seu anúncio foi publicado com sucesso na comunidade!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      controller.setTabIndex(0); // return to explore
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceMd,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Criar Novo Anúncio',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'Monetize seus equipamentos parados com segurança e caução garantida.',
                style: TextStyle(fontSize: 12, color: AppTheme.outline),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // Photos Placeholder Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_a_photo_rounded,
                        size: 36, color: AppTheme.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicionar Fotos do Equipamento',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recomendamos fotos claras do estado atual para a vistoria.',
                      style: TextStyle(fontSize: 11, color: AppTheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Title Input
              Text('Título do Anúncio',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Furadeira Bosch 650W + Brocas',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Informe um título'
                    : null,
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Category Selector
              Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: controller.categories
                    .where((c) => c != 'Todas')
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Description Input
              Text('Descrição e Acessórios Inclusos',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Conte mais detalhes sobre conservação, itens inclusos e cuidados...',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Prices: Daily & Deposit
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valor Diária (R\$)',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '60'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Informe o valor'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Caução Sugerida (R\$)',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '300'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Informe a caução'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    _isSaving ? 'Publicando...' : 'Publicar Anúncio',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
