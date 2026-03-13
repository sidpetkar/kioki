import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';
import '../providers/settings_notifier.dart';
import '../theme.dart';
import '../widgets/card_grid.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  GamePhase? _prevPhase;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Duration _lastElapsed = Duration.zero;

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;
    final timerEnabled = ref.read(settingsProvider).timerEnabled;
    if (timerEnabled) {
      ref.read(gameProvider.notifier).tick(dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handlePhaseTransition(GamePhase phase) {
    if (_prevPhase == GamePhase.levelComplete && phase == GamePhase.peeking) {
      _fadeController.reverse();
    }
    if (phase == GamePhase.levelComplete && _prevPhase != GamePhase.levelComplete) {
      _fadeController.forward();
    }
    _prevPhase = phase;
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(gameProvider.select((s) => s.phase));
    final timerEnabled = ref.watch(settingsProvider).timerEnabled;

    final shouldPauseTicker = phase == GamePhase.paused ||
        phase == GamePhase.gameOver ||
        phase == GamePhase.peeking;
    _ticker.muted = shouldPauseTicker;

    _handlePhaseTransition(phase);

    final isPaused = phase == GamePhase.paused;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: isPaused ? 0.25 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: isPaused,
                      child: _TopBar(timerEnabled: timerEnabled),
                    ),
                  ),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: isPaused ? 0.25 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: IgnorePointer(
                        ignoring: isPaused,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: CardGrid(),
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: isPaused ? 0.25 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: _ComboLabel(),
                  ),
                  _BottomBar(
                    onHome: isPaused
                        ? null
                        : () => Navigator.of(context).pop(),
                    onPause: () =>
                        ref.read(gameProvider.notifier).togglePause(),
                    isPaused: isPaused,
                  ),
                ],
              ),
            ),
            if (phase == GamePhase.gameOver)
              _Overlay(
                title: 'GAME OVER',
                action: 'TAP TO RESTART',
                onTap: () =>
                    ref.read(gameProvider.notifier).restart(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComboLabel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combo = ref.watch(gameProvider.select((s) => s.comboMultiplier));
    final colors = Theme.of(context).colorScheme;

    if (combo <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${combo}X COMBO',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final bool timerEnabled;

  const _TopBar({required this.timerEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(gameProvider.select((s) => s.score));
    final level = ref.watch(gameProvider.select((s) => s.level));
    final timeRemaining =
        ref.watch(gameProvider.select((s) => s.timeRemaining));
    final colors = Theme.of(context).colorScheme;

    final timeDisplay = timeRemaining.ceil().toString().padLeft(2, '0');
    final fraction = (timeRemaining / GameState.maxTime).clamp(0.0, 1.0);
    final barColor = fraction <= 0.2 ? Colors.red : colors.foreground;

    return Column(
      children: [
        if (timerEnabled)
          SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: colors.foreground.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(
                label: 'SCORE',
                value: score.toString().padLeft(2, '0'),
              ),
              if (timerEnabled)
                _StatColumn(
                  label: 'TIME LEFT',
                  value: '${timeDisplay}s',
                ),
              _StatColumn(
                label: 'LEVEL',
                value: level.toString().padLeft(2, '0'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colors.muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: colors.foreground,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback onPause;
  final bool isPaused;

  const _BottomBar({
    required this.onHome,
    required this.onPause,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: isPaused ? 0.25 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: onHome,
              child: Text(
                'HOME',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.foreground,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onPause,
            child: Text(
              isPaused ? 'RESUME' : 'PAUSE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.foreground,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _Overlay({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: colors.bg.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                action,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.muted,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
