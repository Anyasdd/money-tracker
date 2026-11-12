import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/balance_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/add_transaction_bloc.dart';
import '../repositories/transaction_repository.dart';
import '../utils/money_format.dart';

import 'transactions_screen.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Открываем историю операций
  Future<void> _openHistory(BuildContext context) async {
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

    // Пересчитываем баланс после возврата
    context.read<BalanceBloc>().add(BalanceRequested());
  }

  // Открываем статистику
  void _openStatistics(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              TransactionsBloc(TransactionRepository())
                ..add(TransactionsRequested()),
          child: const StatisticsScreen(),
        ),
      ),
    );
  }

  // Добавляем новую операцию
  Future<void> _openAddTransaction(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider(
          create: (_) => AddTransactionBloc(TransactionRepository()),
          child: const AddTransactionScreen(),
        ),
      ),
    );

    if (!context.mounted) return;

    if (saved == true) {
      context.read<BalanceBloc>().add(BalanceRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // Верхняя панель
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FB),
        surfaceTintColor: Colors.transparent,

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF087F70),
            ),
            SizedBox(width: 10),
            Text(
              'Money Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Обновить баланс',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BalanceBloc>().add(BalanceRequested());
            },
          ),
        ],
      ),

      // Кнопка добавления операции
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF087F70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Добавить операцию'),
        onPressed: () {
          _openAddTransaction(context);
        },
      ),

      // Основное содержимое
      body: BlocBuilder<BalanceBloc, BalanceState>(
        builder: (context, state) {
          // Загрузка данных
          if (state is BalanceInitial || state is BalanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ошибка загрузки
          if (state is BalanceFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Не удалось загрузить данные',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(state.message, textAlign: TextAlign.center),

                    const SizedBox(height: 20),

                    FilledButton(
                      onPressed: () {
                        context.read<BalanceBloc>().add(BalanceRequested());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Данные успешно загружены
          if (state is BalanceLoaded) {
            final balance = state.balance;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),

              children: [
                const Text(
                  'Обзор финансов',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Все суммы в сомах (KGS)',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Большая карточка баланса
                Container(
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF075F55), Color(0xFF14A18A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 21,
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Общий баланс',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        formatSom(balance.balance),
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Ваши финансы под контролем',
                        style: TextStyle(
                          color: Color(0xFFD4F5EA),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Доходы и расходы
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Доходы',
                        amount: formatSom(balance.totalIncome),
                        icon: Icons.arrow_downward,
                        color: const Color(0xFF118A64),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _SummaryCard(
                        title: 'Расходы',
                        amount: formatSom(balance.totalExpense),
                        icon: Icons.arrow_upward,
                        color: const Color(0xFFD34D4D),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Быстрые действия',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // История и статистика
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'История',
                        subtitle: 'Все операции',
                        icon: Icons.receipt_long_outlined,
                        onTap: () {
                          _openHistory(context);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _ActionCard(
                        title: 'Статистика',
                        subtitle: 'Анализ расходов',
                        icon: Icons.pie_chart_outline,
                        onTap: () {
                          _openStatistics(context);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Количество операций
                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.list_alt_rounded,
                        color: Color(0xFF087F70),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Всего операций',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      Text(
                        '${balance.transactionCount}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

// Карточка доходов или расходов
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 8),

          Text(
            amount,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Кнопки быстрых действий
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF087F70), size: 28),

              const SizedBox(height: 16),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
