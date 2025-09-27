import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../models/coin.dart';


// Events
abstract class CoinsEvent {}

class CoinsLoadRequested extends CoinsEvent {}

// States
abstract class CoinsState {}

class CoinsInitial extends CoinsState {}

class CoinsLoading extends CoinsState {}

class CoinsLoaded extends CoinsState {

  CoinsLoaded();
}

class CoinsFailure extends CoinsState {
  final String message;
  CoinsFailure(this.message);
}

// Bloc
class CoinsBloc extends Bloc<CoinsEvent, CoinsState> {
  final Dio dio = Dio();
  List<Coin> coins = [];

  CoinsBloc() : super(CoinsInitial()) {
    on<CoinsLoadRequested>(_onLoadRequested);
  }


  Future<void> _onLoadRequested(CoinsLoadRequested event, Emitter<CoinsState> emit) async {
    emit(CoinsLoading());
    try {
      final  response = await dio.get(
        'https://api.coingecko.com/api/v3/coins/list',
        options: Options(responseType: ResponseType.json, headers: <String, String>{'accept': 'application/json'}),
      );
      final data = response.data as List;
      coins = data.map((e) => Coin.fromJson(e as Map<String, dynamic>)).toList();

      emit(CoinsLoaded());
    } catch (e) {
      emit(CoinsFailure(e.toString()));
      print('print error==>${e.toString()}');
    }
  }



}


