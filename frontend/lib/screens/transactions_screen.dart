import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/transactions_bloc.dart';
import '../models/transaction.dart';
import '../bloc/edit_transaction_bloc.dart';
import '../repositories/transaction_repository.dart';
import 'edit_transaction_screen.dart';
import '../utils/money_format.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить операцию?'),

        content: Text(
          'Удалить операцию "${transaction.category}" '
          'на сумму ${formatSom(transaction.amount)}?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Отмена'),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    context.read<TransactionsBloc>().add(
      TransactionDeleteRequested(transaction.id),
    );
  }

  Future<void> _openEdit(BuildContext context, Transaction transaction) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider(
          create: (_) => EditTransactionBloc(TransactionRepository()),

          child: EditTransactionScreen(transaction: transaction),
        ),
      ),
    );

    if (!context.mounted) return;

    if (updated == true) {
      context.read<TransactionsBloc>().add(TransactionsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionsBloc>().add(TransactionsRequested());
            },
          ),
        ],
      ),

      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsInitial || state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TransactionsBloc>().add(
                          TransactionsRequested(),
                        );
                      },
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TransactionsLoaded) {
            final transactions = state.transactions;

            if (transactions.isEmpty) {
              return const Center(
                child: Text(
                  'Пока нет операций',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: transactions.length,

              itemBuilder: (context, index) {
                final Transaction transaction = transactions[index];

                final isIncome = transaction.isIncome;

                final color = isIncome ? Colors.green : Colors.red;

                final description = transaction.description ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),

                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(25),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                      ),
                    ),

                    title: Text(
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description.isNotEmpty) Text(description),

                        Text(
                          formatDate(transaction.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),

                        Text(
                          '${isIncome ? '+' : '−'}${formatSom(transaction.amount)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Меню редактирования и удаления
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Действия с операцией',

                      onSelected: (action) async {
                        if (action == 'edit') {
                          await _openEdit(context, transaction);
                        } else if (action == 'delete') {
                          await _confirmDelete(context, transaction);
                        }
                      },

                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Редактировать'),
                        ),

                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Удалить'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
