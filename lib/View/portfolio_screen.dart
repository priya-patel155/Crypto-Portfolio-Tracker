import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/coins.dart';
import '../blocs/portfolio_bloc.dart';
import '../widgets/add_asset_dialog.dart';
import '../models/portfolio_holding.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CoinsBloc>(
          create: (_) => CoinsBloc()..add(CoinsLoadRequested()),
        ),
        BlocProvider<PortfolioBloc>(
          create: (_) => PortfolioBloc()..add(PortfolioLoadRequested()),
        ),
      ],
      child: BlocBuilder<CoinsBloc, CoinsState>(
        builder: (context, coinsState) {
          return const _PortfolioContent();
        },
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  const _PortfolioContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Portfolio'),
        elevation: 0,
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioError) {
            return _buildErrorState(context, state.message);
          } else if (state is PortfolioLoaded) {
            return _buildPortfolioContent(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<PortfolioBloc>().add(PortfolioLoadRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioContent(BuildContext context, PortfolioLoaded state) {
    final portfolio = state.portfolioData;
    final holdings = portfolio.holdings;
    
    if (holdings!.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PortfolioBloc>().add(PortfolioRefreshRequested());
      },
      child: Column(
        children: [
          _buildTotalValueCard(context, portfolio.totalValue!),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: holdings.length,
              itemBuilder: (context, index) {
                final holding = holdings[index];
                return _buildHoldingCard(context, holding);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Your portfolio is empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first cryptocurrency to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddAssetDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Asset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValueCard(BuildContext context, double totalValue) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Total Portfolio Value',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(totalValue),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(BuildContext context, PortfolioHolding holding) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final quantityFormatter = NumberFormat('#,##0.########');
    
    return Dismissible(
      key: Key(holding.coinId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Coins'),
            content: Text('Are you sure you want to remove ${holding.coinName} from your portfolio?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        context.read<PortfolioBloc>().add(PortfolioRemoveHoldingRequested(holding.coinId));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.coinName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      holding.coinSymbol.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(holding.currentPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${quantityFormatter.format(holding.quantity)} ${holding.coinSymbol.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(holding.totalValue),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAssetDialog(BuildContext context) {
    final coinsState = context.read<CoinsBloc>().state;


    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider<CoinsBloc>.value(
            value: context.read<CoinsBloc>(),
          ),
          BlocProvider<PortfolioBloc>.value(
            value: context.read<PortfolioBloc>(),
          ),
        ],
        child: const AddAssetDialog(),
      ),
    );
  }
}