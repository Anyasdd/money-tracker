import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:money_tracker/bloc/balance_bloc.dart';
import 'package:money_tracker/models/balance.dart';
import 'package:money_tracker/repositories/balance_repository.dart';

// Подменяем настоящий Repository тестовым.
class MockBalanceRepository extends Mock implements BalanceRepository {}

void main() {
  late MockBalanceRepository repository;

  setUp(() {
    repository = MockBalanceRepository();
  });

  final testBalance = Balance(
    totalIncome: '17000.00',
    totalExpense: '250.50',
    balance: '16749.50',
    transactionCount: 2,
  );

  // TEST 1: Successful API response
  blocTest<BalanceBloc, BalanceState>(
    'emits Loading and Loaded when request succeeds',

    setUp: () {
      when(() => repository.fetchBalance())
          .thenAnswer((_) async => testBalance);
    },

    build: () => BalanceBloc(repository),

    act: (bloc) {
      bloc.add(BalanceRequested());
    },

    expect: () => [
      isA<BalanceLoading>(),
      isA<BalanceLoaded>().having(
        (state) => state.balance.balance,
        'balance',
        '16749.50',
      ),
    ],

    verify: (_) {
      verify(() => repository.fetchBalance()).called(1);
    },
  );

  // TEST 2: Failed API response
  blocTest<BalanceBloc, BalanceState>(
    'emits Loading and Failure when request fails',

    setUp: () {
      when(() => repository.fetchBalance())
          .thenThrow(Exception('Server unavailable'));
    },

    build: () => BalanceBloc(repository),

    act: (bloc) {
      bloc.add(BalanceRequested());
    },

    expect: () => [isA<BalanceLoading>(), isA<BalanceFailure>()],
  );
}
