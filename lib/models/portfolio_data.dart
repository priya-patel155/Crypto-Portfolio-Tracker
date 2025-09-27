import 'package:crypto_portfolio_tracker/models/portfolio_holding.dart';

import '../database/database_helper.dart';

class PortfolioData {
  final List<PortfolioHolding>? holdings;
  final double? totalValue;

  const PortfolioData({
     this.holdings,
     this.totalValue,
  });

  factory PortfolioData.empty() {
    return const PortfolioData(holdings: [], totalValue: 0.0);
  }

  PortfolioData copyWith({
    List<PortfolioHolding>? holdings,
    double? totalValue,
  }) {
    return PortfolioData(
      holdings: holdings ?? this.holdings,
      totalValue: totalValue ?? this.totalValue,
    );
  }



  static Future<void> save(PortfolioData portfolio) async {
    final db = PortfolioDatabase.instance;

    for (final holding in portfolio.holdings!) {
      await db.upsertHolding(holding);
    }
    await db.savePortfolio(portfolio);
  }


  static Future<PortfolioData> load() async {
    return await PortfolioDatabase.instance.loadPortfolio();
  }

  static Future<void> clear() async {
    final db = PortfolioDatabase.instance;
    final database = await db.database;
    await database.delete('holdings');
    await database.delete('portfolio');
  }
  static Future<void> removeHolding(String coinId) async {
    final db = PortfolioDatabase.instance;
    final database = await db.database;

    await database.delete(
      'holdings',
      where: 'coinId = ?',
      whereArgs: [coinId],
    );
  }


}
