import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/models/balance.dart';

void main() {
  test('Balance model parses JSON correctly', () {
    final json = {
      'total_income': '17000.00',
      'total_expense': '250.50',
      'balance': '16749.50',
      'transaction_count': 2,
    };

    final balance = Balance.fromJson(json);

    expect(balance.totalIncome, '17000.00');
    expect(balance.totalExpense, '250.50');
    expect(balance.balance, '16749.50');
    expect(balance.transactionCount, 2);
  });
}
