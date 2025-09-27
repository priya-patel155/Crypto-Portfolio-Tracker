class PortfolioItem {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final double quantity;

  PortfolioItem({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.quantity,
  });

  // Convert PortfolioItem to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'quantity': quantity,
    };
  }

  // Create PortfolioItem from JSON
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'],
      coinName: json['coinName'],
      coinSymbol: json['coinSymbol'],
      quantity: (json['quantity'] as num).toDouble(),
    );
  }
}
