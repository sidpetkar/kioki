import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';

class GameNotifier extends Notifier<GameState> {
  final _random = Random();
  bool _disposed = false;

  @override
  GameState build() {
    ref.onDispose(() => _disposed = true);
    final initial = const GameState();
    return _generateCards(initial);
  }

  GameState _generateCards(GameState s) {
    final totalCards = s.totalCards;
    final pairCount = totalCards ~/ 2;

    final numbers = List<int>.generate(100, (i) => i)..shuffle(_random);
    final selected = numbers.take(pairCount).toList();

    final cardValues = <String>[];
    for (final num in selected) {
      final label = num.toString().padLeft(2, '0');
      cardValues.addAll([label, label]);
    }
    cardValues.shuffle(_random);

    final cards = List<CardModel>.generate(
      cardValues.length,
      (i) => CardModel(id: 'card_${s.level}_$i', value: cardValues[i]),
    );

    return s.copyWith(
      cards: cards,
      firstFlippedIndex: () => null,
      secondFlippedIndex: () => null,
      isLocked: false,
      phase: GamePhase.playing,
      timeRemaining: GameState.maxTime,
    );
  }

  void flipCard(int index) {
    if (state.isLocked) return;
    if (state.phase != GamePhase.playing) return;

    final card = state.cards[index];
    if (card.isFaceUp || card.isMatched) return;

    final updatedCards = List<CardModel>.from(state.cards);
    updatedCards[index] = card.copyWith(isFaceUp: true);

    if (state.firstFlippedIndex == null) {
      state = state.copyWith(
        cards: updatedCards,
        firstFlippedIndex: () => index,
      );
    } else {
      state = state.copyWith(
        cards: updatedCards,
        secondFlippedIndex: () => index,
        isLocked: true,
      );
      _checkMatch();
    }
  }

  void _checkMatch() {
    final first = state.firstFlippedIndex!;
    final second = state.secondFlippedIndex!;
    final cards = state.cards;

    if (cards[first].value == cards[second].value) {
      _handleMatch(first, second);
    } else {
      _handleMismatch(first, second);
    }
  }

  void _handleMatch(int first, int second) {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_disposed) return;

      final updatedCards = List<CardModel>.from(state.cards);
      updatedCards[first] = updatedCards[first].copyWith(isMatched: true);
      updatedCards[second] = updatedCards[second].copyWith(isMatched: true);

      final newConsecutive = state.consecutiveMatches + 1;
      int newMultiplier = 1;
      if (newConsecutive >= 4) {
        newMultiplier = 4;
      } else if (newConsecutive >= 2) {
        newMultiplier = 2;
      }

      final newScore = state.score + (10 * state.comboMultiplier);
      final newTime = (state.timeRemaining + 3).clamp(0.0, GameState.maxTime);

      state = state.copyWith(
        cards: updatedCards,
        score: newScore,
        comboMultiplier: newMultiplier,
        consecutiveMatches: newConsecutive,
        timeRemaining: newTime,
        firstFlippedIndex: () => null,
        secondFlippedIndex: () => null,
        isLocked: true,
      );

      Future.delayed(const Duration(milliseconds: 700), () {
        if (_disposed) return;
        state = state.copyWith(isLocked: false);
        _checkLevelComplete();
      });
    });
  }

  void _handleMismatch(int first, int second) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_disposed) return;

      final updatedCards = List<CardModel>.from(state.cards);
      updatedCards[first] = updatedCards[first].copyWith(isFaceUp: false);
      updatedCards[second] = updatedCards[second].copyWith(isFaceUp: false);

      final newTime = (state.timeRemaining - 1).clamp(0.0, GameState.maxTime);

      state = state.copyWith(
        cards: updatedCards,
        comboMultiplier: 1,
        consecutiveMatches: 0,
        timeRemaining: newTime,
        firstFlippedIndex: () => null,
        secondFlippedIndex: () => null,
        isLocked: false,
      );

      if (newTime <= 0) {
        state = state.copyWith(phase: GamePhase.gameOver);
      }
    });
  }

  void _checkLevelComplete() {
    final allMatched = state.cards.every((c) => c.isMatched);
    if (allMatched) {
      state = state.copyWith(phase: GamePhase.levelComplete);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_disposed) return;
        _advanceLevel();
      });
    }
  }

  void _advanceLevel() {
    final maxLevel = 10;
    if (state.level >= maxLevel) return;
    final nextState = GameState(
      level: state.level + 1,
      score: state.score,
      comboMultiplier: 1,
      consecutiveMatches: 0,
    );
    state = _generateCards(nextState);
  }

  void tick(double dt) {
    if (state.phase != GamePhase.playing) return;
    final newTime = (state.timeRemaining - dt).clamp(0.0, GameState.maxTime);
    state = state.copyWith(timeRemaining: newTime);
    if (newTime <= 0) {
      state = state.copyWith(phase: GamePhase.gameOver);
    }
  }

  void togglePause() {
    if (state.phase == GamePhase.playing) {
      state = state.copyWith(phase: GamePhase.paused);
    } else if (state.phase == GamePhase.paused) {
      state = state.copyWith(phase: GamePhase.playing);
    }
  }

  void restart() {
    _disposed = false;
    state = _generateCards(const GameState());
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
