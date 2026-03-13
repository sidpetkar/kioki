import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../providers/game_notifier.dart';
import 'flip_card.dart';

class CardGrid extends ConsumerStatefulWidget {
  const CardGrid({super.key});

  @override
  ConsumerState<CardGrid> createState() => _CardGridState();
}

class _CardGridState extends ConsumerState<CardGrid>
    with TickerProviderStateMixin {
  final Map<String, _CardSlot> _slots = {};
  final Set<String> _fadingOut = {};
  static const Duration _slideDuration = Duration(milliseconds: 400);
  static const Duration _fadeDuration = Duration(milliseconds: 300);
  static const Curve _slideCurve = Curves.easeInOut;
  static const double _spacing = 4;

  static const double _baseCardWidth = 44;
  static const double _baseCardHeight = 58;

  double _cardWidth = _baseCardWidth;
  double _cardHeight = _baseCardHeight;
  int _columns = 4;
  int _currentLevel = -1;

  void _clearSlots() {
    for (final slot in _slots.values) {
      slot.fadeController?.dispose();
    }
    _slots.clear();
    _fadingOut.clear();
  }

  @override
  void dispose() {
    for (final slot in _slots.values) {
      slot.fadeController?.dispose();
    }
    super.dispose();
  }

  void _computeCardSize(BoxConstraints constraints, int columns, int rowCount) {
    _columns = columns;

    final maxGridWidth = constraints.maxWidth;
    final widthBasedCard =
        (maxGridWidth - (columns - 1) * _spacing) / columns;

    final scale = widthBasedCard / _baseCardWidth;
    _cardWidth = _baseCardWidth * scale;
    _cardHeight = _baseCardHeight * scale;

    final neededHeight = rowCount * (_cardHeight + _spacing) - _spacing;
    final availableHeight = constraints.maxHeight;

    if (neededHeight > availableHeight) {
      final maxCardHeight =
          (availableHeight + _spacing) / rowCount - _spacing;
      final shrinkScale = maxCardHeight / _cardHeight;
      _cardHeight = maxCardHeight;
      _cardWidth = _cardWidth * shrinkScale;
    }
  }

  Offset _positionForVisualIndex(int visualIndex) {
    final col = visualIndex % _columns;
    final row = visualIndex ~/ _columns;
    return Offset(
      col * (_cardWidth + _spacing),
      row * (_cardHeight + _spacing),
    );
  }

  void _reconcile(List<CardModel> cards) {
    final activeCards = cards
        .where((c) => !c.isMatched && !_fadingOut.contains(c.id))
        .toList();

    final newlyMatched = cards
        .where((c) =>
            c.isMatched &&
            _slots.containsKey(c.id) &&
            !_fadingOut.contains(c.id))
        .toList();

    if (newlyMatched.isNotEmpty) {
      HapticFeedback.heavyImpact();
    }

    for (final card in newlyMatched) {
      _fadingOut.add(card.id);
      final slot = _slots[card.id]!;
      slot.fadeController = AnimationController(
        vsync: this,
        duration: _fadeDuration,
      );
      slot.fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: slot.fadeController!, curve: Curves.easeOut),
      );
      slot.fadeController!.forward().then((_) {
        if (mounted) {
          setState(() {
            _fadingOut.remove(card.id);
            _slots.remove(card.id);
            slot.fadeController?.dispose();
          });
        }
      });
    }

    for (int i = 0; i < activeCards.length; i++) {
      final card = activeCards[i];
      final target = _positionForVisualIndex(i);
      if (_slots.containsKey(card.id)) {
        _slots[card.id]!.targetOffset = target;
      } else {
        _slots[card.id] = _CardSlot(
          card: card,
          currentOffset: target,
          targetOffset: target,
        );
      }
      _slots[card.id]!.card = card;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final cards = gameState.cards;
    final columns = gameState.columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (gameState.level != _currentLevel) {
          _clearSlots();
          _currentLevel = gameState.level;
        }

        final rowCount = (cards.length / columns).ceil();
        _computeCardSize(constraints, columns, rowCount);
        _reconcile(cards);

        final visibleRows = (cards.length / columns).ceil();
        final totalHeight =
            visibleRows * (_cardHeight + _spacing) - _spacing;
        final totalWidth =
            columns * (_cardWidth + _spacing) - _spacing;

        final children = <Widget>[];

        for (final entry in _slots.entries) {
          final slot = entry.value;
          final card = slot.card;
          final isFading = _fadingOut.contains(card.id);

          Widget child = SizedBox(
            width: _cardWidth,
            height: _cardHeight,
            child: FlipCard(
              key: ValueKey(card.id),
              value: card.value,
              isFaceUp: card.isFaceUp,
              isMatched: card.isMatched,
              onTap: () {
                HapticFeedback.lightImpact();
                final currentCards = ref.read(gameProvider).cards;
                final idx =
                    currentCards.indexWhere((c) => c.id == card.id);
                if (idx != -1) {
                  ref.read(gameProvider.notifier).flipCard(idx);
                }
              },
            ),
          );

          if (isFading && slot.fadeAnimation != null) {
            child = FadeTransition(
              opacity: slot.fadeAnimation!,
              child: ScaleTransition(
                scale: slot.fadeAnimation!,
                child: child,
              ),
            );
          }

          children.add(
            AnimatedPositioned(
              key: ValueKey('pos_${card.id}'),
              duration: _slideDuration,
              curve: _slideCurve,
              left: slot.targetOffset.dx,
              top: slot.targetOffset.dy,
              child: child,
            ),
          );
        }

        return Center(
          child: SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: Stack(children: children),
          ),
        );
      },
    );
  }
}

class _CardSlot {
  CardModel card;
  Offset currentOffset;
  Offset targetOffset;
  AnimationController? fadeController;
  Animation<double>? fadeAnimation;

  _CardSlot({
    required this.card,
    required this.currentOffset,
    required this.targetOffset,
  });
}
