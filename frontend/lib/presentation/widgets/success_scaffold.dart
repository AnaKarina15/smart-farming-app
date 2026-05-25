import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import 'offline_banner.dart';
import '../screens/home_screen.dart';
import '../screens/tasks_screen.dart';

import '../screens/lotes_list_screen.dart';
import 'dart:async';

/// Layout reusable para pantallas de éxito (riego, fertilización, siembra…).
class SuccessScaffold extends StatefulWidget {
  final String title;
  final String onlineSubtitle;
  final String offlineSubtitle;
  final String location;
  final String detailLabel;
  final String detailValue;
  final IconData detailIcon;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final AgroTab currentTab;

  const SuccessScaffold({
    super.key,
    required this.title,
    required this.onlineSubtitle,
    required this.offlineSubtitle,
    required this.location,
    required this.detailLabel,
    required this.detailValue,
    required this.detailIcon,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.imageUrl,
    this.fallbackIcon,
    this.currentTab = AgroTab.home,
  });

  @override
  State<SuccessScaffold> createState() => _SuccessScaffoldState();
}

class _SuccessScaffoldState extends State<SuccessScaffold> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (widget.onPrimaryPressed != null) {
          widget.onPrimaryPressed!();
        } else {
          Widget destination;
          if (widget.currentTab == AgroTab.lotes) {
            destination = const LotesListScreen();
          } else if (widget.currentTab == AgroTab.tareas) {
            destination = const TasksScreen();
          } else {
            destination = const HomeScreen();
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => destination));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      // ── Success Icon ─────────────────────────
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixedDim,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                      Text(
                        widget.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppText.h2(color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: OfflineBanner.showGlobal,
                          builder: (context, isOffline, child) {
                            return Text(
                              isOffline
                                  ? widget.offlineSubtitle
                                  : widget.onlineSubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.bodyMd(
                                color: AppColors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ── Summary Card ─────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'RESUMEN DE REGISTRO',
                                  style: AppText.labelCaps(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _row('Ubicación', widget.location,
                                AppColors.onSurface),
                            const SizedBox(height: 14),
                            const Divider(
                              color: AppColors.outlineVariant,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  widget.detailIcon,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.detailLabel.toUpperCase(),
                                        style: AppText.labelCaps(
                                            color: AppColors.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.detailValue,
                                        style: AppText.bodyMd(
                                                color: AppColors.onSurface)
                                            .copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ── Media / Additional Space ─────────────
                      if (widget.imageUrl != null)
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (widget.fallbackIcon != null)
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            widget.fallbackIcon,
                            size: 48,
                            color: AppColors.outline,
                          ),
                        ),
                      if (widget.imageUrl != null ||
                          widget.fallbackIcon != null)
                        const SizedBox(height: 25),

                      // ── Primary Action ───────────────────────
                      if (widget.primaryButtonText != null)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            onPressed: widget.onPrimaryPressed,
                            child: Text(
                              widget.primaryButtonText!,
                              style: AppText.labelCaps(
                                color: AppColors.onPrimary,
                              ).copyWith(fontSize: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppText.labelCaps(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppText.bodyMd(color: valueColor).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
