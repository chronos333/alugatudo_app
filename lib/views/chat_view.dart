import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../models/chat_model.dart';
import '../models/rental_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/network_image_fallback.dart';
import '../widgets/pin_modal.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _msgInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _highlightVistoria = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(AlugaController controller) {
    final text = _msgInputController.text;
    if (text.trim().isEmpty) return;
    controller.sendMessage(text);
    _msgInputController.clear();
    _scrollToBottom();
  }

  void _sendInspectionPhoto(AlugaController controller) {
    controller.sendInspectionPhoto();
    _scrollToBottom();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto de vistoria anexada com sucesso à conversa!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageFallback(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Carimbo de data/hora e geolocalização auditados na Blockchain AlugaTudo.',
                    style: TextStyle(fontSize: 10, color: AppTheme.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final rental = controller.currentRental;
    final messages = controller.chatMessages;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Conversa Direta',
      ),
      body: Column(
        children: [
          // Scrollable Chat & Status Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.marginMobile,
                vertical: AppTheme.spaceMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CARD STATUS DA RESERVA
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
                        // Status badge + ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 13, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    rental.status.label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                rental.id,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spaceMd),

                        // Item Title & Pickup info
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: const Icon(Icons.calendar_today_rounded,
                                  size: 20, color: AppTheme.primary),
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rental.itemTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Retirada: Sex, 18 Out às 10:00 (Estação Pinheiros)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spaceLg),

                        // Compact Stepper (Solicitado -> Pago -> Em Curso -> Finalizado)
                        _buildCompactStepper(rental.status),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceSm),

                  // 2. AÇÕES RÁPIDAS DE SEGURANÇA (TOP ACTION BAR)
                  Row(
                    children: [
                      // Button 1: Código PIN
                      Expanded(
                        child: InkWell(
                          onTap: () => PinModalBottomSheet.show(context,
                              pinCode: rental.pinCode),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.pin_rounded,
                                      size: 18, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Código PIN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        rental.pinCode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Button 2: Vistoria Prévia
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _highlightVistoria = true);
                            Future.delayed(const Duration(milliseconds: 1500),
                                () {
                              if (mounted) {
                                setState(() => _highlightVistoria = false);
                              }
                            });
                          },
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 18,
                                      color: AppTheme.onSurfaceVariant),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vistoria Prévia',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '3 Registradas',
                                        style: TextStyle(
                                          fontSize: 11,
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
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spaceSm),

                  // 3. BANNER EDUCATIVO DE SEGURANÇA
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_rounded,
                            size: 18, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.onSurfaceVariant,
                                  height: 1.3),
                              children: [
                                TextSpan(
                                  text: 'Caução em custódia. ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurface),
                                ),
                                TextSpan(
                                  text:
                                      'Só libere o código PIN após receber o equipamento e conferir os itens pessoalmente.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceMd),

                  // Date Divider: Hoje, 17 de Outubro
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: const Text(
                        'HOJE, 17 DE OUTUBRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceMd),

                  // 4. CHAT MESSAGES TIMELINE
                  ...messages.map((msg) {
                    return _buildMessageItem(context, msg, rental);
                  }),
                ],
              ),
            ),
          ),

          // 5. INPUT DE MENSAGEM & ANEXOS (STICKY BOTTOM BAR)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              boxShadow: AppTheme.elevatedShadow,
              border: const Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Camera attachment button
                  IconButton(
                    icon: const Icon(Icons.photo_camera_rounded,
                        color: AppTheme.onSurfaceVariant),
                    tooltip: 'Anexar foto de vistoria',
                    onPressed: () => _sendInspectionPhoto(controller),
                  ),

                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: TextField(
                        controller: _msgInputController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Escreva para Lucas...',
                          hintStyle: TextStyle(
                              color: AppTheme.outline, fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          filled: false,
                        ),
                        onSubmitted: (_) => _sendMessage(controller),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Send button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                      onPressed: () => _sendMessage(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStepper(RentalStatus status) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Gray Background Line
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: AppTheme.surfaceContainerHigh,
            ),
            // Green Progress Line
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2,
                width: MediaQuery.of(context).size.width * 0.45,
                margin: const EdgeInsets.only(left: 20),
                color: AppTheme.primaryContainer,
              ),
            ),
            // 4 Steps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step 1: Solicitado
                _StepCircle(
                  icon: Icons.check_rounded,
                  isActive: true,
                  isCompleted: true,
                  label: 'Solicitado',
                ),
                // Step 2: Pago
                _StepCircle(
                  icon: Icons.done_all_rounded,
                  isActive: true,
                  isCompleted: false,
                  label: 'Pago',
                  isCurrent: true,
                ),
                // Step 3: Em Curso
                _StepCircle(
                  icon: Icons.schedule_rounded,
                  isActive: false,
                  isCompleted: false,
                  label: 'Em Curso',
                ),
                // Step 4: Finalizado
                _StepCircle(
                  icon: Icons.verified_rounded,
                  isActive: false,
                  isCompleted: false,
                  label: 'Finalizado',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageItem(
      BuildContext context, ChatMessage msg, RentalModel rental) {
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    if (msg.type == MessageType.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.key_rounded,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (msg.type == MessageType.inspectionCard) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: _highlightVistoria
                ? AppTheme.primaryContainer
                : const Color(0xFFE2E8F0),
            width: _highlightVistoria ? 2 : 1,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 16, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Vistoria Fotográfica Prévia',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${rental.inspectionPhotos.length} fotos anexadas',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              msg.text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // 3 Thumbnail Images Grid
            Row(
              children: rental.inspectionPhotos.map((photo) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => _showImageDialog(
                          context, photo.imageUrl, photo.title),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: NetworkImageFallback(
                                imageUrl: photo.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 3,
                              right: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.inverseSurface
                                      .withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  photo.label,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    if (msg.type == MessageType.host) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  msg.senderInitials ?? 'LM',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${msg.senderName} • Proprietário',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // User Message
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
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

class _StepCircle extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final bool isCurrent;
  final String label;

  const _StepCircle({
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    this.isCurrent = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive
                ? (isCurrent ? AppTheme.primaryContainer : AppTheme.primary)
                : AppTheme.surfaceContainerHigh,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 12,
            color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            color: isCurrent ? AppTheme.primary : AppTheme.outline,
          ),
        ),
      ],
    );
  }
}
