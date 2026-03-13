import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class FlipCard extends StatefulWidget {
  final String value;
  final String? suit;
  final bool isFaceUp;
  final bool isMatched;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.value,
    this.suit,
    required this.isFaceUp,
    required this.isMatched,
    required this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _redSuits = {'heart', 'diamond'};
  static const _suitRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isFaceUp) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp != oldWidget.isFaceUp) {
      if (widget.isFaceUp) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFront = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final colors = Theme.of(context).colorScheme;

    if (widget.suit != null) {
      return _buildSymbolFront(colors);
    }
    return _buildDigitFront(colors);
  }

  Widget _buildDigitFront(ColorScheme colors) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardFront,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.foreground, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolFront(ColorScheme colors) {
    final isRed = _redSuits.contains(widget.suit);
    final suitColor = isRed ? _suitRed : colors.foreground;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final rankSize = (h * 0.30).clamp(10.0, 28.0);
          final iconSize = (h * 0.30).clamp(10.0, 30.0);
          final pad = (h * 0.06).clamp(2.0, 6.0);

          return Container(
            decoration: BoxDecoration(
              color: colors.cardFront,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: suitColor, width: 1.5),
            ),
            padding: EdgeInsets.all(pad),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: rankSize,
                      fontWeight: FontWeight.w800,
                      color: suitColor,
                      height: 1,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SvgPicture.asset(
                    'assets/${widget.suit}-icon.svg',
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(suitColor, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBack,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
