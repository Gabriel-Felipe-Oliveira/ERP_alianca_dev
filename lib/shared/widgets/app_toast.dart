import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/app_feedback.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

OverlayEntry? _activeFeedbackEntry;
Timer? _autoDismissTimer;

/// Exibe feedback padronizado (modal com ícone, título, mensagem e OK).
/// Toque **fora** do card ou no botão **OK** fecha. Apenas um feedback por vez.
void showAppFeedback(
  BuildContext context, {
  required AppFeedbackMessage feedback,
  OverlayState? overlay,
}) {
  final overlayState = overlay ?? Overlay.maybeOf(context);
  if (overlayState == null) return;

  _dismissFeedbackImmediate();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _AppFeedbackOverlay(
      feedback: feedback,
      onDismiss: () => _removeEntry(entry),
    ),
  );

  _activeFeedbackEntry = entry;
  overlayState.insert(entry);

  _autoDismissTimer = Timer(feedback.displayDuration, () {
    _dismissFeedbackImmediate();
  });
}

/// Atalho para sucesso.
void showAppSuccess(
  BuildContext context, {
  required String message,
  Duration? duration,
  OverlayState? overlay,
}) {
  showAppFeedback(
    context,
    feedback: AppFeedbackMessage.success(message, duration: duration),
    overlay: overlay,
  );
}

/// Atalho para erro.
void showAppError(
  BuildContext context, {
  required String message,
  Duration? duration,
  OverlayState? overlay,
}) {
  showAppFeedback(
    context,
    feedback: AppFeedbackMessage.error(message, duration: duration),
    overlay: overlay,
  );
}

/// Compatível com chamadas existentes — delega para [showAppFeedback].
void showAppToast(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration? duration,
  OverlayState? overlay,
  ScaffoldMessengerState? messenger,
}) {
  showAppFeedback(
    context,
    feedback: isError
        ? AppFeedbackMessage.error(message, duration: duration)
        : AppFeedbackMessage.success(message, duration: duration),
    overlay: overlay,
  );
}

void _removeEntry(OverlayEntry entry) {
  _autoDismissTimer?.cancel();
  _autoDismissTimer = null;
  if (entry.mounted) entry.remove();
  if (_activeFeedbackEntry == entry) _activeFeedbackEntry = null;
}

void _dismissFeedbackImmediate() {
  final entry = _activeFeedbackEntry;
  if (entry != null) _removeEntry(entry);
}

class _AppFeedbackOverlay extends StatefulWidget {
  const _AppFeedbackOverlay({
    required this.feedback,
    required this.onDismiss,
  });

  final AppFeedbackMessage feedback;
  final VoidCallback onDismiss;

  @override
  State<_AppFeedbackOverlay> createState() => _AppFeedbackOverlayState();
}

class _AppFeedbackOverlayState extends State<_AppFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _closing = false;

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: AppColors.cardShadowColor,
          blurRadius: AppSpacing.formContainerShadowBlurRadius,
          offset: Offset(0, AppSpacing.formContainerShadowOffsetY),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_closing) return;
    _closing = true;
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.feedback.accentColor;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: FadeTransition(
                opacity: _opacity,
                child: Container(
                  color: AppColors.background.withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _opacity,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 340,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.formContainer),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: _cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _FeedbackIconBadge(
                      icon: widget.feedback.icon,
                      color: accent,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.feedback.displayTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        widget.feedback.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: SizedBox(
                        width: double.infinity,
                        height: AppSpacing.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.button),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackIconBadge extends StatelessWidget {
  const _FeedbackIconBadge({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 36,
      ),
    );
  }
}
