import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/transaction_repository.dart';

// EVENTS

sealed class EditTransactionEvent {}

class EditTransactionSubmitted extends EditTransactionEvent {
  final int id;
  final String type;
  final String amount;
  final String category;
  final String? description;

  EditTransactionSubmitted({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
  });
}

// STATES

sealed class EditTransactionState {}

class EditTransactionInitial extends EditTransactionState {}

class EditTransactionSaving extends EditTransactionState {}

class EditTransactionSuccess extends EditTransactionState {}

class EditTransactionFailure extends EditTransactionState {
  final String message;

  EditTransactionFailure(this.message);
}

// BLOC

class EditTransactionBloc
    extends Bloc<EditTransactionEvent, EditTransactionState> {
  final TransactionRepository repository;

  EditTransactionBloc(this.repository) : super(EditTransactionInitial()) {
    on<EditTransactionSubmitted>((event, emit) async {
      emit(EditTransactionSaving());

      try {
        await repository.updateTransaction(
          id: event.id,
          type: event.type,
          amount: event.amount,
          category: event.category,
          description: event.description,
        );

        emit(EditTransactionSuccess());
      } catch (e) {
        emit(EditTransactionFailure(e.toString()));
      }
    });
  }
}
