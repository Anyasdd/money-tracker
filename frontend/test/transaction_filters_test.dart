import 'package:flutter_test/flutter_test.dart';

import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/transaction_filters.dart';

void main() {
  final transactions = [
    Transaction(
      id: 1,
      type: 'income',
      amount: '17000.00',
      category: 'Зарплата',
      description: 'Зарплата за месяц',
      createdAt: DateTime(2026, 11, 11, 12),
    ),
    Transaction(
      id: 2,
      type: 'expense',
      amount: '450.50',
      category: 'Еда',
      description: 'Обед в кафе',
      createdAt: DateTime(2026, 11, 12, 10),
    ),
    Transaction(
      id: 3,
      type: 'expense',
      amount: '250.00',
      category: 'Транспорт',
      description: 'Такси',
      createdAt: DateTime(2026, 11, 12, 14),
    ),
    Transaction(
      id: 4,
      type: 'expense',
      amount: '100.00',
      category: 'Еда',
      description: null,
      createdAt: DateTime(2026, 10, 20),
    ),
  ];

  test('Search finds Russian text in descriptions', () {
    final result = filterTransactions(transactions, query: 'КАФЕ');

    expect(result.length, 1);
    expect(result.first.id, 2);
  });

  test('Search finds categories ignoring case', () {
    final result = filterTransactions(transactions, query: 'еДа');

    expect(result.map((t) => t.id).toList(), [2, 4]);
  });

  test('Income and expense filters work', () {
    final incomes = filterTransactions(
      transactions,
      filter: TransactionFilter.income,
    );

    final expenses = filterTransactions(
      transactions,
      filter: TransactionFilter.expense,
    );

    expect(incomes.length, 1);
    expect(incomes.first.id, 1);

    expect(expenses.map((t) => t.id).toList(), [3, 2, 4]);
  });

  test('Transactions are grouped by day', () {
    final filtered = filterTransactions(transactions);
    final groups = groupTransactionsByDay(filtered);

    expect(groups.length, 3);

    expect(groups.keys.first, DateTime(2026, 11, 12));

    expect(groups.values.first.map((t) => t.id).toList(), [3, 2]);
  });
}
