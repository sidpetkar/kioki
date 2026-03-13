import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_notifier.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    'SETTINGS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                      letterSpacing: 6,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 22,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SettingsRow(
              label: 'TIMER',
              value: settings.timerEnabled,
              onTap: () => ref.read(settingsProvider.notifier).toggleTimer(),
            ),
            const SizedBox(height: 24),
            _SettingsRow(
              label: 'DARK MODE',
              value: settings.isDarkMode,
              onTap: () => ref.read(settingsProvider.notifier).toggleDarkMode(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.foreground,
              letterSpacing: 4,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value
                    ? colors.foreground
                    : colors.foreground.withValues(alpha: 0.15),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.bg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
