class CardModel {
  final String id;
  final String value;
  final bool isFaceUp;
  final bool isMatched;

  const CardModel({
    required this.id,
    required this.value,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return CardModel(
      id: id,
      value: value,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
