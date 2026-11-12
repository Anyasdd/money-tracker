import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/expense_statistics.dart';

void main() {
  test('Expenses are grouped by category and month', () {
    final transactions = [
      Transaction(
        id: 1,
        type: 'expense',
        amount: '250.50',
        category: 'Еда',
        description: null,
        createdAt: DateTime(2026, 11, 5),
      ),
      Transaction(
        id: 2,
        type: 'expense',
        amount: '100.25',
        category: 'Еда',
        description: null,
        createdAt: DateTime(2026, 11, 6),
      ),
      Transaction(
        id: 3,
        type: 'income',
        amount: '1000.00',
        category: 'Зарплата',
        description: null,
        createdAt: DateTime(2026, 11, 6),
      ),
      Transaction(
        id: 4,
        type: 'expense',
        amount: '500.00',
        category: 'Транспорт',
        description: null,
        createdAt: DateTime(2026, 10, 10),
      ),
    ];

    final result = expensesForMonth(transactions, DateTime(2026, 11));

    expect(result.length, 1);
    expect(result.first.category, 'Еда');
    expect(result.first.totalTyiyn, 35075);
  });
}
