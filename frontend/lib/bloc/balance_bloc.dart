import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/balance.dart';
import '../repositories/balance_repository.dart';

// EVENTS
sealed class BalanceEvent {}

class BalanceRequested extends BalanceEvent {}


// STATES
sealed class BalanceState {}

class BalanceInitial extends BalanceState {}

class BalanceLoading extends BalanceState {}

class BalanceLoaded extends BalanceState {
  final Balance balance;

  BalanceLoaded(this.balance);
}

class BalanceFailure extends BalanceState {
  final String message;

  BalanceFailure(this.message);
}


// BLOC
class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final BalanceRepository repository;

  BalanceBloc(this.repository) : super(BalanceInitial()) {
    on<BalanceRequested>((event, emit) async {
      emit(BalanceLoading());

      try {
        final balance = await repository.fetchBalance();

        emit(BalanceLoaded(balance));
      } catch (e) {
        emit(BalanceFailure(e.toString()));
      }
    });
  }
}