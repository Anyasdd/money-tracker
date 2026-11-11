import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/models/transaction.dart';

void main() {
  test('Transaction model parses JSON correctly', () {
    final json = {
      'id': 1,
      'type': 'expense',
      'amount': '250.50',
      'category': 'Еда',
      'description': 'Обед в кафе',
      'created_at': '2026-11-05T07:00:00Z',
    };

    final transaction = Transaction.fromJson(json);

    expect(transaction.id, 1);
    expect(transaction.isIncome, false);
    expect(transaction.amount, '250.50');
    expect(transaction.category, 'Еда');
    expect(transaction.description, 'Обед в кафе');
  });
}