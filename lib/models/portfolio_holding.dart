class PortfolioHolding {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final double quantity;
  final double currentPrice;

  const PortfolioHolding({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.quantity,
    this.currentPrice = 0.0,
  });

  double get totalValue => quantity * currentPrice;

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'quantity': quantity,
      'currentPrice': currentPrice,
    };
  }

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      coinId: json['coinId'] as String,
      coinName: json['coinName'] as String,
      coinSymbol: json['coinSymbol'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  PortfolioHolding copyWith({
    String? coinId,
    String? coinName,
    String? coinSymbol,
    double? quantity,
    double? currentPrice,
  }) {
    return PortfolioHolding(
      coinId: coinId ?? this.coinId,
      coinName: coinName ?? this.coinName,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}

