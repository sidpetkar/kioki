import 'card_model.dart';

enum GamePhase { playing, paused, gameOver, levelComplete }

class LevelConfig {
  final int columns;
  final int rows;

  const LevelConfig(this.columns, this.rows);

  int get totalCards => columns * rows;

  static LevelConfig forLevel(int level) {
    switch (level) {
      case 1:
        return const LevelConfig(4, 2);
      case 2:
        return const LevelConfig(6, 2);
      case 3:
        return const LevelConfig(6, 3);
      case 4:
        return const LevelConfig(8, 3);
      case 5:
        return const LevelConfig(8, 4);
      default:
        final rows = (level - 2).clamp(5, 8);
        return LevelConfig(8, rows);
    }
  }
}

class GameState {
  final List<CardModel> cards;
  final int score;
  final int comboMultiplier;
  final int consecutiveMatches;
  final double timeRemaining;
  final int level;
  final int? firstFlippedIndex;
  final int? secondFlippedIndex;
  final bool isLocked;
  final GamePhase phase;

  static const double maxTime = 45.0;

  const GameState({
    this.cards = const [],
    this.score = 0,
    this.comboMultiplier = 1,
    this.consecutiveMatches = 0,
    this.timeRemaining = maxTime,
    this.level = 1,
    this.firstFlippedIndex,
    this.secondFlippedIndex,
    this.isLocked = false,
    this.phase = GamePhase.playing,
  });

  LevelConfig get levelConfig => LevelConfig.forLevel(level);
  int get columns => levelConfig.columns;
  int get rows => levelConfig.rows;
  int get totalCards => levelConfig.totalCards;

  GameState copyWith({
    List<CardModel>? cards,
    int? score,
    int? comboMultiplier,
    int? consecutiveMatches,
    double? timeRemaining,
    int? level,
    int? Function()? firstFlippedIndex,
    int? Function()? secondFlippedIndex,
    bool? isLocked,
    GamePhase? phase,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      score: score ?? this.score,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      consecutiveMatches: consecutiveMatches ?? this.consecutiveMatches,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      level: level ?? this.level,
      firstFlippedIndex: firstFlippedIndex != null
          ? firstFlippedIndex()
          : this.firstFlippedIndex,
      secondFlippedIndex: secondFlippedIndex != null
          ? secondFlippedIndex()
          : this.secondFlippedIndex,
      isLocked: isLocked ?? this.isLocked,
      phase: phase ?? this.phase,
    );
  }
}
