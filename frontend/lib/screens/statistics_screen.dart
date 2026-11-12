import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/transactions_bloc.dart';
import '../utils/expense_statistics.dart';
import '../utils/money_format.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  static const months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const colors = [
    Colors.teal,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.green,
    Colors.brown,
    Colors.indigo,
  ];

  void _changeMonth(int difference) {
    setState(() {
      _month = DateTime(_month.year, _month.month + difference);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionsBloc>().add(
                        TransactionsRequested(),
                      );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionsLoaded) {
            final expenses = expensesForMonth(state.transactions, _month);

            final total = expenses.fold<int>(
              0,
              (sum, item) => sum + item.totalTyiyn,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Переключение месяцев
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),

                    Text(
                      '${months[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Сумма расходов
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Расходы за месяц'),

                        const SizedBox(height: 8),

                        Text(
                          formatTyiyn(total),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (total == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Нет расходов за этот месяц',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  // Круговая диаграмма
                  SizedBox(
                    height: 240,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 45,
                        sectionsSpace: 2,

                        sections: List.generate(expenses.length, (index) {
                          final item = expenses[index];

                          final percent = item.totalTyiyn * 100 / total;

                          return PieChartSectionData(
                            value: item.totalTyiyn.toDouble(),
                            color: colors[index % colors.length],
                            radius: 65,

                            title: percent >= 7
                                ? '${percent.toStringAsFixed(0)}%'
                                : '',

                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Расходы по категориям',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // Список категорий
                  ...List.generate(expenses.length, (index) {
                    final item = expenses[index];

                    final percent = item.totalTyiyn * 100 / total;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors[index % colors.length],
                          radius: 10,
                        ),

                        title: Text(item.category),

                        subtitle: Text('${percent.toStringAsFixed(1)}%'),

                        trailing: Text(
                          formatTyiyn(item.totalTyiyn),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
