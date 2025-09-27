class Coin {
  final String id;
  final String symbol;
  final String name;

  const Coin({required this.id, required this.symbol, required this.name});

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: (json['id'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}


