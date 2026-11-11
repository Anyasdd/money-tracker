import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/transaction_repository.dart';

// EVENTS

sealed class AddTransactionEvent {}

class AddTransactionSubmitted extends AddTransactionEvent {
  final String type;
  final String amount;
  final String category;
  final String? description;

  AddTransactionSubmitted({
    required this.type,
    required this.amount,
    required this.category,
    this.description,
  });
}

// STATES

sealed class AddTransactionState {}

class AddTransactionInitial extends AddTransactionState {}

class AddTransactionSubmitting extends AddTransactionState {}

class AddTransactionSuccess extends AddTransactionState {}

class AddTransactionFailure extends AddTransactionState {
  final String message;

  AddTransactionFailure(this.message);
}

// BLOC

class AddTransactionBloc
    extends Bloc<AddTransactionEvent, AddTransactionState> {
  final TransactionRepository repository;

  AddTransactionBloc(this.repository) : super(AddTransactionInitial()) {
    on<AddTransactionSubmitted>((event, emit) async {
      emit(AddTransactionSubmitting());

      try {
        await repository.createTransaction(
          type: event.type,
          amount: event.amount,
          category: event.category,
          description: event.description,
        );

        emit(AddTransactionSuccess());
      } catch (e) {
        emit(AddTransactionFailure(e.toString()));
      }
    });
  }
}
