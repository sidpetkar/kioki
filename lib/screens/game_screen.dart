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
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(gameProvider.select((s) => s.phase));
    final timerEnabled = ref.watch(settingsProvider).timerEnabled;

    final shouldPauseTicker =
        phase == GamePhase.paused || phase == GamePhase.gameOver;
    _ticker.muted = shouldPauseTicker;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(timerEnabled: timerEnabled),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: CardGrid(),
                  ),
                ),
                _BottomBar(
                  onHome: () => Navigator.of(context).pop(),
                  onPause: () =>
                      ref.read(gameProvider.notifier).togglePause(),
                  isPaused: phase == GamePhase.paused,
                ),
              ],
            ),
            if (phase == GamePhase.paused)
              _Overlay(
                title: 'PAUSED',
                action: 'TAP TO RESUME',
                onTap: () =>
                    ref.read(gameProvider.notifier).togglePause(),
              ),
            if (phase == GamePhase.gameOver)
              _Overlay(
                title: 'GAME OVER',
                action: 'TAP TO RESTART',
                onTap: () =>
                    ref.read(gameProvider.notifier).restart(),
              ),
            if (phase == GamePhase.levelComplete)
              _Overlay(
                title: 'LEVEL CLEAR',
                action: 'LOADING NEXT...',
                onTap: () {},
              ),
          ],
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
    final combo = ref.watch(gameProvider.select((s) => s.comboMultiplier));

    final timeDisplay = timeRemaining.ceil().toString().padLeft(2, '0');

    return Column(
      children: [
        if (timerEnabled)
          SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: (timeRemaining / GameState.maxTime).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.dark.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.dark),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            children: [
              Row(
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
              if (combo > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${combo}X COMBO',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      letterSpacing: 4,
                    ),
                  ),
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
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onPause;
  final bool isPaused;

  const _BottomBar({
    required this.onHome,
    required this.onPause,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onHome,
            child: Text(
              'HOME',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.dark,
                letterSpacing: 4,
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
                color: AppColors.dark,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.background.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                action,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
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
