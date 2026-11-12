import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/edit_transaction_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../utils/money_format.dart';
import '../utils/transaction_filters.dart';

import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';
  TransactionFilter _filter = TransactionFilter.all;

  static const _months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  // Красивое отображение даты
  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  // Скрываем технические метки демо-операций
  String _cleanDescription(String? description) {
    final text = description ?? '';
    final markerIndex = text.indexOf('[DEMO MT]');

    if (markerIndex >= 0) {
      return text.substring(0, markerIndex).trim();
    }

    return text.trim();
  }

  // Иконка зависит от категории
  IconData _categoryIcon(Transaction transaction) {
    switch (transaction.category.toLowerCase()) {
      case 'еда':
        return Icons.restaurant;
      case 'транспорт':
        return Icons.directions_bus;
      case 'покупки':
        return Icons.shopping_bag_outlined;
      case 'жильё':
        return Icons.home_outlined;
      case 'развлечения':
        return Icons.movie_outlined;
      case 'здоровье':
        return Icons.medical_services_outlined;
      case 'учёба':
        return Icons.school_outlined;
      case 'зарплата':
        return Icons.payments_outlined;
      case 'подработка':
        return Icons.work_outline;
      default:
        return transaction.isIncome
            ? Icons.trending_up
            : Icons.category_outlined;
    }
  }

  // Подтверждение удаления
  Future<void> _confirmDelete(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить операцию?'),
        content: Text(
          'Удалить "${transaction.category}" '
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
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    context.read<TransactionsBloc>().add(
      TransactionDeleteRequested(transaction.id),
    );
  }

  // Открываем редактирование
  Future<void> _openEdit(Transaction transaction) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider(
          create: (_) => EditTransactionBloc(TransactionRepository()),
          child: EditTransactionScreen(transaction: transaction),
        ),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      context.read<TransactionsBloc>().add(TransactionsRequested());
    }
  }

  // Один фильтр: Все, Доходы или Расходы
  Widget _filterChip(String title, TransactionFilter value) {
    return ChoiceChip(
      label: Text(title),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }

  // Карточка одной транзакции
  Widget _transactionCard(Transaction transaction) {
    final isIncome = transaction.isIncome;

    final color = isIncome ? const Color(0xFF118A64) : const Color(0xFFD34D4D);

    final description = _cleanDescription(transaction.description);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),

        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(25),
            child: Icon(_categoryIcon(transaction), color: color),
          ),

          title: Text(
            transaction.category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description.isNotEmpty)
                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),

              const SizedBox(height: 6),

              Text(
                '${isIncome ? '+' : '−'}'
                '${formatSom(transaction.amount)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Редактирование и удаление
          trailing: PopupMenuButton<String>(
            tooltip: 'Действия с операцией',

            onSelected: (action) async {
              if (action == 'edit') {
                await _openEdit(transaction);
              } else if (action == 'delete') {
                await _confirmDelete(transaction);
              }
            },

            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Редактировать'),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Удалить', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

      body: Column(
        children: [
          // Поиск и фильтры
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск по операциям',
                    prefixIcon: const Icon(Icons.search),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('Все', TransactionFilter.all),
                    _filterChip('Доходы', TransactionFilter.income),
                    _filterChip('Расходы', TransactionFilter.expense),
                  ],
                ),
              ],
            ),
          ),

          // История загружается через BLoC
          Expanded(
            child: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state is TransactionsInitial ||
                    state is TransactionsLoading) {
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
                            color: Colors.red,
                            size: 48,
                          ),

                          const SizedBox(height: 12),

                          Text(state.message, textAlign: TextAlign.center),

                          const SizedBox(height: 12),

                          FilledButton(
                            onPressed: () {
                              context.read<TransactionsBloc>().add(
                                TransactionsRequested(),
                              );
                            },
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is TransactionsLoaded) {
                  if (state.transactions.isEmpty) {
                    return const Center(child: Text('Пока нет операций'));
                  }

                  // Применяем поиск и фильтр
                  final filtered = filterTransactions(
                    state.transactions,
                    query: _search,
                    filter: _filter,
                  );

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('По запросу ничего не найдено'),
                    );
                  }

                  // Группируем по датам
                  final groups = groupTransactionsByDay(filtered).entries
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),

                    itemCount: groups.length,

                    itemBuilder: (context, index) {
                      final group = groups[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 0, 12),

                            child: Text(
                              _formatDate(group.key),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          ...group.value.map(_transactionCard),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
