import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../models/portfolio_data.dart';
import '../models/portfolio_holding.dart';
abstract class PortfolioEvent {}

class PortfolioLoadRequested extends PortfolioEvent {}

class PortfolioRefreshRequested extends PortfolioEvent {}

class PortfolioAddHoldingRequested extends PortfolioEvent {
  final PortfolioHolding holding;
  PortfolioAddHoldingRequested(this.holding);
}

class PortfolioRemoveHoldingRequested extends PortfolioEvent {
  final String coinId;
  PortfolioRemoveHoldingRequested(this.coinId);
}

class PortfolioUpdatePricesRequested extends PortfolioEvent {}


abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final PortfolioData portfolioData;
  final bool isRefreshing;

  PortfolioLoaded({
    required this.portfolioData,
    this.isRefreshing = false,
  });
}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final Dio dio;
  PortfolioData _portfolioData = PortfolioData();

  PortfolioBloc({Dio? dio}) 
      : dio = dio ?? Dio(),
        super(PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoadRequested);
    on<PortfolioRefreshRequested>(_onRefreshRequested);
    on<PortfolioAddHoldingRequested>(_onAddHoldingRequested);
    on<PortfolioRemoveHoldingRequested>(_onRemoveHoldingRequested);
    on<PortfolioUpdatePricesRequested>(_onUpdatePricesRequested);
  }

  Future<void> _onLoadRequested(PortfolioLoadRequested event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    try {
      _portfolioData = await PortfolioData.load();
      await _updatePrices();
      emit(PortfolioLoaded(portfolioData: _portfolioData));
    } catch (e) {
      emit(PortfolioError('Failed to load portfolio: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(PortfolioRefreshRequested event, Emitter<PortfolioState> emit) async {
    if (state is PortfolioLoaded) {
      emit(PortfolioLoaded(portfolioData: _portfolioData, isRefreshing: true));
      try {
        await _updatePrices();
        emit(PortfolioLoaded(portfolioData: _portfolioData));
      } catch (e) {
        emit(PortfolioError(e.toString()));
      }
    }
  }

  Future<void> _onAddHoldingRequested(PortfolioAddHoldingRequested event, Emitter<PortfolioState> emit) async {
    try {
      final existingIndex = _portfolioData.holdings!.indexWhere((h) => h.coinId == event.holding.coinId);

      List<PortfolioHolding> updatedHoldings;
      if (existingIndex != -1) {
        updatedHoldings = List.from(_portfolioData.holdings!);
        updatedHoldings[existingIndex] = updatedHoldings[existingIndex].copyWith(
          quantity: updatedHoldings[existingIndex].quantity + event.holding.quantity,
        );
      } else {
        updatedHoldings = List.from(_portfolioData.holdings!)..add(event.holding);
      }

      _portfolioData = _portfolioData.copyWith(holdings: updatedHoldings);
      await _updatePrices();
      await PortfolioData.save(_portfolioData);
      emit(PortfolioLoaded(portfolioData: _portfolioData));
    } catch (e) {
      emit(PortfolioError('Failed to add holding: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveHoldingRequested(
      PortfolioRemoveHoldingRequested event,
      Emitter<PortfolioState> emit,
      ) async {
    try {
      final updatedHoldings = _portfolioData.holdings!
          .where((h) => h.coinId != event.coinId)
          .toList();

      _portfolioData = _portfolioData.copyWith(holdings: updatedHoldings);
      await PortfolioData.removeHolding(event.coinId);
      await _updatePrices();
      emit(PortfolioLoaded(portfolioData: _portfolioData));
    } catch (e) {
      emit(PortfolioError('Failed to remove holding: ${e.toString()}'));
    }
  }


  Future<void> _onUpdatePricesRequested(PortfolioUpdatePricesRequested event, Emitter<PortfolioState> emit) async {
    try {
      await _updatePrices();
      emit(PortfolioLoaded(portfolioData: _portfolioData));
    } catch (e) {
     emit(PortfolioError(e.toString()));

    }
  }

  Future<void> _updatePrices() async {
    if (_portfolioData.holdings!.isEmpty) {
      _portfolioData = _portfolioData.copyWith(totalValue: 0);
      return;
    }

    try {
      final ids = _portfolioData.holdings!.map((h) => h.coinId).join(',');
      final res = await dio.get(
        'https://api.coingecko.com/api/v3/simple/price',
        queryParameters: {'ids': ids, 'vs_currencies': 'usd'},
      );

      final prices = Map<String, dynamic>.from(res.data);
      final updated = _portfolioData.holdings!.map((h) {
        final price = (prices[h.coinId]?['usd'] as num?)?.toDouble() ?? 0;
        return h.copyWith(currentPrice: price);
      }).toList();

      final total = updated.fold<double>(0, (sum, h) => sum + h.totalValue);
      _portfolioData = _portfolioData.copyWith(holdings: updated, totalValue: total);
    } catch (e) {
      print('${e}');

    }
  }

}
