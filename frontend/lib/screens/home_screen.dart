import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/balance_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/add_transaction_bloc.dart';

import '../repositories/transaction_repository.dart';

import 'transactions_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Tracker'),
        actions: [
          // Открыть историю транзакций
          IconButton(
            tooltip: 'История операций',
            icon: const Icon(Icons.receipt_long),

            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        TransactionsBloc(TransactionRepository())
                          ..add(TransactionsRequested()),

                    child: const TransactionsScreen(),
                  ),
                ),
              );

              if (!context.mounted) return;

              // Обновляем баланс после возврата из истории
              context.read<BalanceBloc>().add(BalanceRequested());
            },
          ),

          // Обновить баланс
          IconButton(
            tooltip: 'Обновить баланс',
            icon: const Icon(Icons.refresh),

            onPressed: () {
              context.read<BalanceBloc>().add(BalanceRequested());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),

        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => AddTransactionBloc(TransactionRepository()),

                child: const AddTransactionScreen(),
              ),
            ),
          );

          if (!context.mounted) return;

          // Обновляем баланс после добавления
          if (saved == true) {
            context.read<BalanceBloc>().add(BalanceRequested());
          }
        },
      ),

      body: BlocBuilder<BalanceBloc, BalanceState>(
        builder: (context, state) {
          // Пока данные загружаются
          if (state is BalanceInitial || state is BalanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Если произошла ошибка
          if (state is BalanceFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ошибка: ${state.message}'),

                  ElevatedButton(
                    onPressed: () {
                      context.read<BalanceBloc>().add(BalanceRequested());
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          // Если данные успешно загрузились
          if (state is BalanceLoaded) {
            final balance = state.balance;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Общий баланс'),

                        const SizedBox(height: 12),

                        Text(
                          '${balance.balance} сом',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: const Text('Доходы'),
                          subtitle: Text('${balance.totalIncome} сом'),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: const Text('Расходы'),
                          subtitle: Text('${balance.totalExpense} сом'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    title: const Text('Всего операций'),
                    trailing: Text('${balance.transactionCount}'),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
