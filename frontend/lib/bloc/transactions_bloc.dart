import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

// EVENTS

sealed class TransactionsEvent {}

class TransactionsRequested extends TransactionsEvent {}

// STATES

sealed class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;

  TransactionsLoaded(this.transactions);
}

class TransactionsFailure extends TransactionsState {
  final String message;

  TransactionsFailure(this.message);
}

// BLOC

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository repository;

  TransactionsBloc(this.repository) : super(TransactionsInitial()) {
    on<TransactionsRequested>((event, emit) async {
      emit(TransactionsLoading());

      try {
        final transactions = await repository.fetchTransactions();

        emit(TransactionsLoaded(transactions));
      } catch (e) {
        emit(TransactionsFailure(e.toString()));
      }
    });
  }
}
