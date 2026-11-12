import '../models/transaction.dart';
import 'money_format.dart';

class CategoryExpense {
  final String category;
  final int totalTyiyn;

  const CategoryExpense({required this.category, required this.totalTyiyn});
}

List<CategoryExpense> expensesForMonth(
  List<Transaction> transactions,
  DateTime month,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    // Учитываем только расходы выбранного месяца.
    if (transaction.isIncome ||
        transaction.createdAt.year != month.year ||
        transaction.createdAt.month != month.month) {
      continue;
    }

    final category = transaction.category;
    final amount = somToTyiyn(transaction.amount);

    totals[category] = (totals[category] ?? 0) + amount;
  }

  final result = totals.entries.map((entry) {
    return CategoryExpense(category: entry.key, totalTyiyn: entry.value);
  }).toList();

  // Самые большие расходы будут первыми.
  result.sort((a, b) => b.totalTyiyn.compareTo(a.totalTyiyn));

  return result;
}
